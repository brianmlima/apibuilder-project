require 'erb'
require 'fileutils'
# require_relative 'app_config.rb'
# require_relative 'templates.rb'
# require_relative 'util.rb'

module ApibuilderProject

  class SpringPom

    TEMPLATE_FILE_NAME = "spring-pom.xml.erb"
    TEMPLATE_CONTENT = IO.read(File.absolute_path(File.expand_path("#{File.dirname(__FILE__)}/../templates/#{TEMPLATE_FILE_NAME}")))
    OUTPUT_FILE_NAME = "pom.xml"

    def SpringPom.write(config)
      Preconditions.assert_class(config, ApibuilderProject::AppConfig)
      groupId = config.group_id
      file_out = File.absolute_path(File.expand_path("#{config.project_base_dir}/#{OUTPUT_FILE_NAME}"))
      message = ERB.new(TEMPLATE_CONTENT, 0, "%<>")
      content = message.result(binding)
      IO.write(file_out, content)
    end
  end

  class JavaSpring

    def JavaSpring.build(appConfig)
      mkdirs(appConfig)
      writeTemplates(appConfig)
    end


    def JavaSpring.mkdirs(appConfig)
      base = appConfig.target_directory

      Util.mkdirs("#{base}/src/main/java")
      Util.mkdirs("#{base}/src/main/resources")
      Util.mkdirs("#{base}/src/test/java")
      Util.mkdirs("#{base}/src/test/resources")
      Util.mkdirs("#{base}/generated")
    end

    def JavaSpring.writeTemplates(appConfig)
      ApibuilderProject::SpringPom.write(appConfig)
    end

  end






end


