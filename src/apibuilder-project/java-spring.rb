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

  # class SpringApplicationClass
  #   TEMPLATE_FILE_NAME = "spring-application-class.java.erb"
  #   TEMPLATE_CONTENT = IO.read(File.absolute_path(File.expand_path("#{File.dirname(__FILE__)}/../templates/#{TEMPLATE_FILE_NAME}")))
  #   # OUTPUT_FILE_NAME = "pom.xml"
  #   def SpringPom.write(config)
  #     Preconditions.assert_class(config, ApibuilderProject::JavaSpringConfig)
  #     groupId = config.group_id
  #     package = config.
  #       className = config.application.split(/[\.]/).collect(&:capitalize).join
  #     file_out = File.absolute_path(File.expand_path("#{config.project_base_dir}/#{TEMPLATE_FILE_NAME}"))
  #     message = ERB.new(TEMPLATE_CONTENT, 0, "%<>")
  #     content = message.result(binding)
  #     IO.write(file_out, content)
  #   end
  # end

  class JavaSourceDirs
    attr_reader :project_base,
                :generated_base,
                :src_base,
                :src_main,
                :src_main_java,
                :src_main_java_project_package,
                :src_main_resources,
                :src_main_resources_project_package,
                :src_test,
                :src_test_java,
                :src_test_java_project_package,
                :src_test_resources,
                :src_test_resources_project_package

    def initialize(appConfig)

      @project_base = appConfig.project_base_dir
      project_package_paths = "#{appConfig.project_package.split(/[\.]/).join("/")}"
      @generated_base = "#{@project_base}/generated"
      @src_base = "#{@project_base}/src"

      @src_main = "#{@src_base}/main"
      @src_main_java = "#{@src_main}/java"
      @src_main_java_project_package = "#{@src_main_java}/#{project_package_paths}"
      @src_main_resources = "#{@src_main}/resources"
      @src_main_resources_project_package = "#{@src_main_resources}/#{project_package_paths}"

      @src_test = "#{@src_base}/test"
      @src_test_java = "#{@src_test}/java"
      @src_test_java_project_package = "#{@src_test_java}/#{project_package_paths}"
      @src_test_resources = "#{@src_test}/resources"
      @src_test_resources_project_package = "#{@src_test_resources}/#{project_package_paths}"

    end
  end

  class JavaSpringConfig

    attr_reader :app_config,
                :group_id,
                :project_package

    def initialize(appConfig)
      @app_config = appConfig
      @group_id = appConfig.group_id
      @project_package = appConfig.project_package
    end
  end

  class JavaSpring
    attr_reader :config,
                :dirs

    def initialize(appConfig)
      @config = ApibuilderProject::JavaSpringConfig.new(appConfig)
      @dirs = ApibuilderProject::JavaSourceDirs.new(appConfig)
    end

    def build()
      mkdirs()
      writeTemplates()
    end

    def mkdirs()
      Util.mkdirs(@dirs.src_main_java_project_package)
      Util.mkdirs(@dirs.src_main_resources_project_package)
      Util.mkdirs(@dirs.src_test_java_project_package)
      Util.mkdirs(@dirs.src_test_resources_project_package)
      Util.mkdirs(@dirs.generated_base)
    end

    def writeTemplates()
      copyStaticFiles()
      applicationClass()
      springPom()
      lombokConfig()
    end

    def copyStaticFiles()
      project_base_dir = @config.app_config.project_base_dir
      staticResources = [
        StaticResource.new(
          Util.absolute_path("#{File.dirname(__FILE__)}/../templates/conf"),
          Util.absolute_path("#{project_base_dir}"),
          true),
        StaticResource.new(
          Util.absolute_path("#{File.dirname(__FILE__)}/../templates/.mvn"),
          Util.absolute_path("#{project_base_dir}"),
          true),
        StaticResource.new(
          Util.absolute_path("#{File.dirname(__FILE__)}/../templates/java/mvnw.cmd"),
          Util.absolute_path("#{project_base_dir}"),
          false),
        StaticResource.new(
          Util.absolute_path("#{File.dirname(__FILE__)}/../templates/java/mvnw"),
          Util.absolute_path("#{project_base_dir}"),
          false)
      ]
      Util.copyFiles(staticResources)
    end

    def applicationClass()
      templateFileName = "spring-application-class.java.erb"
      templateContent = IO.read(File.absolute_path(File.expand_path("#{File.dirname(__FILE__)}/../templates/#{templateFileName}")))
      application = @config.app_config.application
      groupId = @config.group_id
      package = @config.project_package
      className = @config.app_config.application.split(/[\-\_\.]/).collect(&:capitalize).join()
      file_out = File.absolute_path(File.expand_path("#{@dirs.src_main_java_project_package}/#{className}.java"))
      message = ERB.new(templateContent, 0, "%<>")
      content = message.result(binding)
      IO.write(file_out, content)
    end

    def springPom()
      templateFileName = "spring-pom.xml.erb"
      templateContent = IO.read(File.absolute_path(File.expand_path("#{File.dirname(__FILE__)}/../templates/#{templateFileName}")))
      groupId = @config.group_id
      artifactId = @config.app_config.application
      package = @config.project_package
      version = @config.app_config.version
      mainClassName = @config.app_config.application.split(/[\-\_\.]/).collect(&:capitalize).join()
      file_out = File.absolute_path(File.expand_path("#{@dirs.project_base}/pom.xml"))
      message = ERB.new(templateContent, 0, "%<>")
      content = message.result(binding)
      IO.write(file_out, content)
    end

    def lombokConfig()
      templateFileName = "lombok.config.erb"
      templateContent = IO.read(File.absolute_path(File.expand_path("#{File.dirname(__FILE__)}/../templates/#{templateFileName}")))
      file_out = File.absolute_path(File.expand_path("#{@dirs.project_base}/lombok.config"))
      message = ERB.new(templateContent, 0, "%<>")
      content = message.result(binding)
      IO.write(file_out, content)
    end

  end
end


