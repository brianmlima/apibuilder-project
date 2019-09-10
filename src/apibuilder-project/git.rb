require 'git'
require 'octokit'

module ApibuilderProject

  class GitProject

    # attr_reader :organization, :application, :version, :project_base_dir, :git_remote

    def GitProject.init(organization:, application:, version:, project_base_dir:, git_remote:)

      Preconditions.check_not_blank(organization)
      Preconditions.check_not_blank(application)
      Preconditions.check_not_blank(version)
      Preconditions.check_not_blank(project_base_dir)
      Preconditions.check_not_blank(git_remote)
      git = Git::Base.init(project_base_dir)
      # puts git.inspect

      git.add_remote("origin", git_remote)
      git.add
      git.commit("Automated Initial Project Commit")
      git.push

    end
  end

  class GithubProject
    attr_reader :client, :access_token, :git_user, :project_name, :repo_exists, :remote

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


end
