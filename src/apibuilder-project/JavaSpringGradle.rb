require 'erb'
require 'fileutils'

module ApibuilderProject

  class JavaSpringGradle
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
      Preconditions.assert_class(appConfig, ApibuilderProject::AppConfig)

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

  class GradleWrapper
    BASE_DIR = IO.read(File.absolute_path(File.expand_path("#{File.dirname(__FILE__)}/../templates/java/gradle/wrapper")))
  end

  class GradleSettings
    TEMPLATE_FILE_NAME = "settings.gradle.erb"
    TEMPLATE_CONTENT = IO.read(File.absolute_path(File.expand_path("#{File.dirname(__FILE__)}/../templates/java/gradle/#{TEMPLATE_FILE_NAME}")))
    OUTPUT_FILE_NAME = "TEMPLATE_FILE_NAME".delete_suffix(".erb")

    def GradleSettings.write(config)
      Preconditions.assert_class(config, ApibuilderProject::AppConfig)
      groupId = config.group_id
      file_out = File.absolute_path(File.expand_path("#{config.project_base_dir}/#{OUTPUT_FILE_NAME}"))
      message = ERB.new(TEMPLATE_CONTENT, 0, "%<>")
      content = message.result(binding)
      IO.write(file_out, content)
    end
  end

  class GradleBuild
    TEMPLATE_FILE_NAME = "build.gradle.erb"
    TEMPLATE_CONTENT = IO.read(File.absolute_path(File.expand_path("#{File.dirname(__FILE__)}/../templates/java/gradle/#{TEMPLATE_FILE_NAME}")))
    OUTPUT_FILE_NAME = "TEMPLATE_FILE_NAME".delete_suffix(".erb")

    def GradleBuild.write(config)
      Preconditions.assert_class(config, ApibuilderProject::AppConfig)
      groupId = config.group_id
      file_out = File.absolute_path(File.expand_path("#{config.project_base_dir}/#{OUTPUT_FILE_NAME}"))
      message = ERB.new(TEMPLATE_CONTENT, 0, "%<>")
      content = message.result(binding)
      IO.write(file_out, content)
    end
  end

end


