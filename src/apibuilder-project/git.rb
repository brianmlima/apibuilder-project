require 'git'

module ApibuilderProject

  class GitProject

    attr_reader :organization, :application, :version, :project_base_dir, :git_remote

    def initialize(organization:, application:, version:, project_base_dir:, git_remote:)
      @organization = organization
      @application = application
      @version = version
      @project_base_dir = project_base_dir
      @git_remote = git_remote
      @git = Git::Base.init(@project_base_dir)
      puts @git.inspect

      @git.add_remote("origin", @git_remote)
      @git.add
      @git.commit("Automated Initial Commit")
      @git.push

    end

  end

end
