require 'erb'
require 'fileutils'
# require_relative 'app_config.rb'
# require_relative 'templates.rb'
# require_relative 'util.rb'

module ApibuilderProject

  # class SpringPom
  #   TEMPLATE_FILE_NAME = "spring-pom.xml.erb"
  #   TEMPLATE_CONTENT = IO.read(File.absolute_path(File.expand_path("#{File.dirname(__FILE__)}/../templates/#{TEMPLATE_FILE_NAME}")))
  #   OUTPUT_FILE_NAME = "pom.xml"
  #
  #   def SpringPom.write(config)
  #     Preconditions.assert_class(config, ApibuilderProject::AppConfig)
  #     groupId = config.group_id
  #     file_out = File.absolute_path(File.expand_path("#{config.project_base_dir}/#{OUTPUT_FILE_NAME}"))
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

      @project_base = Util.absolute_path(appConfig.project_base_dir)
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

  class JavaConfig

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
                :dirs,
                :projectBaseDir,
                :templateHome,
                :gradleTemplateHome,
                :mavenTemplateHome,
                :maven,
                :gradle

    def initialize(appConfig)
      @config = ApibuilderProject::JavaConfig.new(appConfig)
      @dirs = ApibuilderProject::JavaSourceDirs.new(appConfig)
      @templateHome = Util.absolute_path("#{File.dirname(__FILE__)}/../templates")
      @gradleTemplateHome = "#{@templateHome}/java/gradle"
      @mavenTemplateHome = "#{@templateHome}/java/maven"
      @projectBaseDir = Util.absolute_path(@config.app_config.project_base_dir)
      @maven = @config.app_config.add_spring_maven
      @gradle = @config.app_config.add_spring_gradle
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
      if (@maven)
        springPom()
      end
      if (@gradle)
        gradleProperties()
        gradleBuild()
      end

      lombokConfig()
    end

    def copyStaticFiles()
      # Files that all configs use
      Util.copyFiles(
        [
          StaticResource.new(
            "#{templateHome}/conf",
            @projectBaseDir,
            true)
        ]
      )
      # Maven specific files
      if (@maven)
        Util.copyFiles(
          [
            StaticResource.new(
              "#{mavenTemplateHome}/wrapper/.mvn",
              @projectBaseDir,
              true),
            StaticResource.new(
              "#{mavenTemplateHome}/wrapper/mvnw.cmd",
              @projectBaseDir,
              false),
            StaticResource.new(
              "#{mavenTemplateHome}/wrapper/mvnw",
              @projectBaseDir,
              false)
          ]
        )
      end

      #Gradle specific files
      if (@gradle)
        Util.copyFiles(
          [
            StaticResource.new(
              "#{@gradleTemplateHome}/wrapper/gradle",
              @projectBaseDir,
              true),
            StaticResource.new(
              "#{@gradleTemplateHome}/wrapper/gradlew",
              @projectBaseDir,
              false),
            StaticResource.new(
              "#{@gradleTemplateHome}/wrapper/gradlew.bat",
              @projectBaseDir,
              false)
          ]
        )
      end
    end

    def applicationClass()
      templateFileName = "spring-application-class.java.erb"
      #Template variables
      application = @config.app_config.application
      groupId = @config.group_id
      package = @config.project_package
      # Write templated content
      className = @config.app_config.application.split(/[\-\_\.]/).collect(&:capitalize).join()
      message = ERB.new(IO.read("#{@templateHome}/#{templateFileName}"), 0, "%<>")
      IO.write(
        "#{@dirs.src_main_java_project_package}/#{className}.java",
        message.result(binding)
      )
    end

    def springPom()
      templateFileName = "spring-pom.xml.erb"
      # Template variables
      groupId = @config.group_id
      artifactId = @config.app_config.application
      package = @config.project_package
      version = @config.app_config.version
      mainClassName = @config.app_config.application.split(/[\-\_\.]/).collect(&:capitalize).join()
      # Write templated content
      IO.write(
        "#{@dirs.project_base}/pom.xml",
        ERB.new(IO.read("#{@templateHome}/#{templateFileName}"), 0, "%<>").result(binding)
      )
    end

    def lombokConfig()
      templateFileName = "lombok.config.erb"
      # Template variables
      # Write templated content
      IO.write(
        "#{@dirs.project_base}/#{templateFileName.delete_suffix(".erb")}",
        ERB.new(IO.read("#{@templateHome}/#{templateFileName}"), 0, "%<>").result(binding)
      )
    end

    def gradleProperties()
      templateFileName = "settings.gradle.erb"
      # Template variables
      rootApplicationName = @config.app_config.application.split(/[\-\_\.]/).collect(&:capitalize).join(" ")
      # Write templated content
      IO.write(
        "#{@dirs.project_base}/#{templateFileName.delete_suffix(".erb")}",
        ERB.new(IO.read("#{@gradleTemplateHome}/#{templateFileName}"), 0, "%<>").result(binding)
      )
    end

    def gradleBuild()
      templateFileName = "build.gradle.erb"
      # Template variables
      # Write templated content
      IO.write(
        "#{@dirs.project_base}/#{templateFileName.delete_suffix(".erb")}",
        ERB.new(IO.read("#{@gradleTemplateHome}/#{templateFileName}"), 0, "%<>").result(binding)
      )
    end

  end
end


