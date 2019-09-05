require 'erb'

module ApibuilderProject
  CONFIG_DIR_NAME = ".apibuilder"
  CONFIG_FILE_NAME = "config"


  CONFIG_FILE_TEMPLATE = %{
# Generated with <%= @script_name %> at <%= Time.now.strftime("%d/%m/%Y %H:%M:%S") %>
settings:
    code.create.directories: true
code:
    <%= @organization %>:
      <%= @application %>:
        version: "<%= @version %>"
        generators:
          openapi:
            target: "src/<%= @application %>"
}.gsub(/^  /, '')

  class GeneratorConfig
    attr_reader :organization, :application, :version, :force, :clean, :project_base_dir

    def initialize(script_name:, organization:, application:, version:, force:, clean:, project_base_dir:)
      @script_name = File.basename(script_name)
      @organization = organization
      @application = application
      @version = version
      @force = force
      @clean = clean
      @project_base_dir = project_base_dir


      @conf_dir = File.absolute_path(File.expand_path("#{@project_base_dir}/#{CONFIG_DIR_NAME}"))
      @conf_file = File.absolute_path(File.expand_path("#{@conf_dir}/#{CONFIG_FILE_NAME}"))


      createConfigDir()
      createConfFile()
    end

    private def createConfigDir()
      if !Dir.exist?(@conf_dir)
        FileUtils.mkdir_p @conf_dir
      end
    end

    def createConfFile()
      message = ERB.new(CONFIG_FILE_TEMPLATE, 0, "%<>")
      # content = message.result(self.get_binding)
      content = message.result(binding)
      IO.write(@conf_file, content)
    end
  end
end
