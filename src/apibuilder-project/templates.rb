require 'erb'
require 'fileutils'


module ApibuilderProject


  class ApiJson

    API_JSON_TEMPLATE_FILE_NAME = "api.erb"
    API_JSON_TEMPLATE_CONTENT = IO.read(File.absolute_path(File.expand_path("#{File.dirname(__FILE__)}/../templates/#{API_JSON_TEMPLATE_FILE_NAME}")))
    API_JSON_OUTPUT_FILE_NAME = "api.json"

    def ApiJson.write(application:, project_base_dir:)
      api_json_file = File.absolute_path(File.expand_path("#{project_base_dir}/#{API_JSON_OUTPUT_FILE_NAME}"))
      message = ERB.new(API_JSON_TEMPLATE_CONTENT, 0, "%<>")
      content = message.result(binding)
      IO.write(api_json_file, content)
    end
  end

  class GeneratorConfig

    TEMPLATE_FILE_NAME = "generator.config.erb"
    TEMPLATE_CONTENT = IO.read(File.absolute_path(File.expand_path("#{File.dirname(__FILE__)}/../templates/#{TEMPLATE_FILE_NAME}")))
    OUTPUT_FILE_NAME = "config"

    CONFIG_DIR_NAME = ".apibuilder"
    CONFIG_FILE_NAME = "config"

    def GeneratorConfig.write(script_name:, organization:, application:, version:, force:, clean:, project_base_dir:)
      script_name = File.basename(script_name)
      conf_dir = File.absolute_path(File.expand_path("#{project_base_dir}/#{CONFIG_DIR_NAME}"))
      conf_file = File.absolute_path(File.expand_path("#{conf_dir}/#{CONFIG_FILE_NAME}"))
      if !Dir.exist?(conf_dir)
        FileUtils.mkdir_p conf_dir
      end
      message = ERB.new(TEMPLATE_CONTENT, 0, "%<>")
      # content = message.result(self.get_binding)
      content = message.result(binding)
      IO.write(conf_file, content)
    end
  end


  class GitIgnore
    OUTPUT_FILE_NAME = ".gitignore"

    def GitIgnore.default_lines
      [".idea", "target"]
    end

    def GitIgnore.write(project_base_dir:, lines:)
      out_file = File.absolute_path(File.expand_path("#{project_base_dir}/#{OUTPUT_FILE_NAME}"))
      IO.write(out_file, lines.join("\n"))
    end
  end

  class ProjectConfig

    TEMPLATE_FILE_NAME = "project-config.yaml.erb"
    TEMPLATE_CONTENT = IO.read(File.absolute_path(File.expand_path("#{File.dirname(__FILE__)}/../templates/#{TEMPLATE_FILE_NAME}")))
    OUTPUT_FILE_NAME = "project-config.yaml"

    def ProjectConfig.write(organization:, application:, version:, project_base_dir:)
      Preconditions.check_not_blank(organization)
      Preconditions.check_not_blank(application)
      Preconditions.check_not_blank(version)
      Preconditions.check_not_blank(project_base_dir)
      out_file = File.absolute_path(File.expand_path("#{project_base_dir}/#{OUTPUT_FILE_NAME}"))
      message = ERB.new(TEMPLATE_CONTENT, 0, "%<>")
      content = message.result(binding)
      IO.write(out_file, content)
    end
  end


  StaticResource = Struct.new(:loc, :dest, :is_dir)

  class StaticFiles

    def StaticFiles.copyFiles(project_base_dir:)

      # puts "called"
      staticResources = [
          StaticResource.new(
              Util.absolute_path("#{File.dirname(__FILE__)}/../templates/bin"),
              Util.absolute_path("#{project_base_dir}"),
              true)
      ]
      staticResources.each do |v|
        if v.is_dir == true
          FileUtils.cp_r v.loc, v.dest
        end
      end
    end
  end


  class ReadMe

    TEMPLATE_FILE_NAME = "README.md.erb"
    TEMPLATE_CONTENT = IO.read(Util.absolute_path("#{File.dirname(__FILE__)}/../templates/#{TEMPLATE_FILE_NAME}"))
    OUTPUT_FILE_NAME = "README.md"

    def ReadMe.write(organization:, application:, version:, project_base_dir:)
      Preconditions.check_not_blank(organization)
      Preconditions.check_not_blank(application)
      Preconditions.check_not_blank(version)
      Preconditions.check_not_blank(project_base_dir)
      version_comment = "Initial Project Commit"

      out_file = Util.absolute_path("#{project_base_dir}/#{OUTPUT_FILE_NAME}")
      message = ERB.new(TEMPLATE_CONTENT, 0, "%<>")
      content = message.result(binding)
      IO.write(out_file, content)

    end

  end


end
