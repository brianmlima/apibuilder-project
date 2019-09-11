require 'git'
require 'octokit'

module ApibuilderProject

  class IntegrationManager
    attr_reader :do_integrations,
                :use_git,
                :use_github,
                :use_apibuilder_io

    def initialize(app_config:)
      Preconditions.assert_class(app_config, ApibuilderProject::AppConfig)
      @app_config = app_config
      @do_integrations = !app_config.local_only
      @use_git = @do_integrations
      @use_github = @do_integrations
      @use_apibuilder_io = @do_integrations

      if @use_git
        @git = Integrations::GitRepository.new(
            :project_base_dir => @app_config.project_base_dir)
      end
      if @use_github
        @gitHub = Integrations::GitHub.new(
            :access_token => @app_config.github_token,
            :project_name => @app_config.project_name)
      end
      if @use_apibuilder_io
        @apibuilder = Integrations::ApibuilderApplication.new(
            :profile => @app_config.apibuilder_profile,
            :token => @app_config.apibuilder_token,
            :organization => @app_config.organization,
            :application => @app_config.application)
      end
    end

    def github_repo_exists
      raiseIfNot(@use_github, "Cant check github for repository existance when the GitHub Integration is disabled")
      @gitHub.repo_exists
    end

    def github_remote
      raiseIfNot(@use_github, "Cant return github repository remote when the GitHub Integration is disabled")
      @gitHub.remote

    end

    def github_repo_create(options: {})
      raiseIfNot(@use_github, "Cant create github repository when the GitHub Integration is disabled")
      @gitHub.create
    end

    def apibuilder_org_exists
      raiseIfNot(@use_apibuilder_io, "Cant create check for organization existance when the apibuilder Integration is disabled")
      @apibuilder.org_exists
    end

    def apibuilder_app_exists
      raiseIfNot(@use_apibuilder_io, "Cant create check for application existance when the apibuilder Integration is disabled")
      @apibuilder.app_exists
    end

    def apibuilder_create_application
      raiseIfNot(@use_apibuilder_io, "Cant create applicaiton when the apibuilder Integration is disabled")
      @apibuilder.create_remote
    end

    def git_init
      raiseIfNot(@use_git, "Cant initialize a git repository when the git Integration is disabled")
      @git.init
    end

    def git_add
      raiseIfNot(@use_git, "Cant add to a git repository when the git Integration is disabled")
      @git.add
    end

    def git_add_remote(git_remote)
      raiseIfNot(@use_git, "Unable to add a remote to a git repository when the git Integration is disabled")
      @git.add_remote(git_remote)
    end

    def git_commit(message)
      raiseIfNot(@use_git, "Unable to commit to a git repository when the git Integration is disabled")
      @git.commit(message)
    end

    def git_push
      raiseIfNot(@use_git, "Unable to push a git repository when the git Integration is disabled")
      return @git.push
    end

    private def raiseIfNot(truthy, message)
      if !truthy
        raise Exception.new(message)
      end
    end

  end

  module Integrations

    class GitRepository

      def initialize(project_base_dir:)
        @project_base_dir = Preconditions.check_not_blank(project_base_dir)
        @has_init = false
      end

      def init
        @git = Git::Base.init(@project_base_dir)
        @has_init = true
      end

      def add_remote(git_remote)
        Preconditions.assert_class(@git, Git::Base)
        Preconditions.check_not_blank(git_remote)
        @git.add_remote("origin", git_remote)
      end

      def add
        Preconditions.assert_class(@git, Git::Base)
        @git.add
      end

      def commit(message)
        Preconditions.assert_class(@git, Git::Base)
        Preconditions.check_not_blank(message)
        @git.commit(message)
      end

      def push
        Preconditions.assert_class(@git, Git::Base)
        @git.push
      end
    end

    class GitHub
      attr_reader :client, :git_user, :project_name, :repo_exists, :remote

      def initialize(access_token:, project_name:)
        @project_name = project_name
        @access_token = access_token
        @client = Octokit::Client.new(:access_token => @access_token)
        @git_user = @client.user
        @repo = Octokit::Repository.new(:user => @git_user.login, :repo => @project_name)
        @repo_exists = @client.repository?(@repo)
        @remote = "https://github.com/#{@git_user.login}/#{@project_name}.git"
      end

      # Create a repository for a user or organization
      #
      # @param name [String] Name of the new repo
      # @option options [String] :description Description of the repo
      # @option options [String] :homepage Home page of the repo
      # @option options [String] :private `true` makes the repository private, and `false` makes it public.
      # @option options [String] :has_issues `true` enables issues for this repo, `false` disables issues.
      # @option options [String] :has_wiki `true` enables wiki for this repo, `false` disables wiki.
      # @option options [Boolean] :is_template `true` makes this repo available as a template repository, `false` to prevent it.
      # @option options [String] :has_downloads `true` enables downloads for this repo, `false` disables downloads.
      # @option options [String] :organization Short name for the org under which to create the repo.
      # @option options [Integer] :team_id The id of the team that will be granted access to this repository. This is only valid when creating a repo in an organization.
      # @option options [Boolean] :auto_init `true` to create an initial commit with empty README. Default is `false`.
      # @option options [String] :gitignore_template Desired language or platform .gitignore template to apply. Ignored if auto_init parameter is not provided.
      # @return [Sawyer::Resource] Repository info for the new repository
      # @see https://developer.github.com/v3/repos/#create
      def create(options: {})
        @client.create_repository(@project_name, options)
      end
    end

    class ApibuilderApplication

      def initialize(profile:, token:, organization:, application:, debug: false)
        @debug = debug
        @organization = organization
        @application = application
        profile = Preconditions.assert_class_or_nil(profile, String)
        token = Preconditions.assert_class_or_nil(token, String)
        @client = ApibuilderCli::Config.client_from_profile(:profile => profile, :token => token)
        @remote_org = @client.organizations.get.find {|org| org.name == @organization}
        @remote_app = @remote_org ? @client.applications.get(@remote_org.key).find {|app| app.name == @application} : false
      end

      def org_exists
        @remote_org ? true : false
      end

      def app_exists()
        @remote_app ? true : false
      end

      def create_remote
        if self.app_exists
          # fail if app already exists, never overwrite, force user to manually delete
          raise Exception.new("Cant not create apibuilder application, #{@application} in organization #@organization} already exists")
        end
        if self.org_exists # check to make sure org exists before we create the app
          application_form = Io::Apibuilder::Api::V0::Models::ApplicationForm.new(
              :name => @application,
              :key => @application,
              :description => "",
              :visibility => Io::Apibuilder::Api::V0::Models::Visibility.organization
          )
          @client.applications.post(@remote_org.key, application_form)
          puts "created apibuilder app"
        else
          raise Exception.new("Cant not create apibuilder application organization #@organization} does not exist")
        end
      end
    end
  end
end
