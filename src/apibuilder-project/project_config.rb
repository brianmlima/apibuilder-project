require 'erb'

module ApibuilderProject

  class ProjectConfig

    TEMPLATE_FILE_NAME = "project-config.yaml.erb"
    TEMPLATE_CONTENT = IO.read(File.absolute_path(File.expand_path("#{File.dirname(__FILE__)}/../templates/#{TEMPLATE_FILE_NAME}")))
    OUTPUT_FILE_NAME = "project-config.yaml"

    attr_reader :organization, :application, :version, :project_base_dir

    def initialize(organization:, application:, version:, project_base_dir:)
      @organization = Preconditions.check_not_blank(organization)
      @application = Preconditions.check_not_blank(application)
      @version = Preconditions.check_not_blank(version)
      @project_base_dir = Preconditions.check_not_blank(project_base_dir)
      @out_file = File.absolute_path(File.expand_path("#{@project_base_dir}/#{OUTPUT_FILE_NAME}"))
      createFile()
    end

    private def createFile()
      message = ERB.new(TEMPLATE_CONTENT, 0, "%<>")
      content = message.result(binding)
      IO.write(@out_file, content)
    end
  end

end
