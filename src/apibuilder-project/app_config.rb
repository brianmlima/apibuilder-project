require 'optparse'
require 'fileutils'

module ApibuilderProject

  class AppConfig

    attr_reader :organization,
                :application,
                :version,
                :target_directory,
                :force, :clean,
                :project_base_dir,
                :github_token_file,
                :github_token,
                :project_name,
                :apibuilder_profile,
                :apibuilder_token,
                :debug,
                :local_only,
                :add_spring_maven,
                :add_spring_gradle,
                :group_id,
                :project_package

    OptionSpec = Struct.new(:short, :long, :type, :description)
    SwitchSpec = Struct.new(:short, :long, :description)

    private def logAndFail(optionParser, message)
      puts message
      puts
      puts optionParser.help
      exit(false)
    end

    private def reqArgMessage(optStruct)
      "Missing required argument for option #{optStruct.short} #{optStruct.long} , #{optStruct.description}"
    end

    def initialize(options, script_path)

      github_token_file_opt = OptionSpec.new("-t", "--token-file TOKEN_FILE", String, "A file that contains a github token")
      org_opt = OptionSpec.new("-o", "--organization ORGANIZATION", String, "(Required) the apibuilder organization key")
      app_opt = OptionSpec.new("-a", "--application APPLICATION", String, "(Required) the apibuilder application key. This should be a dash separated string if multiple words are necessary.")
      version_opt = OptionSpec.new("-v", "--version VERSION", String, "(Required) the application version")
      path_opt = OptionSpec.new("-d", "--destination DESTINATION", String, "(Required) the destination directory where the template will be rendered")
      force_opt = SwitchSpec.new("-f", "--force", "if set the destination directory will be created if it does not exist and existing files will be overwritten")
      clean_opt = SwitchSpec.new("-c", "--clean", "if set and the project destination directory exists all contents will be deleted before continuing")
      debug_opt = SwitchSpec.new("--debug", "", "if set and the project destination directory exists all contents will be deleted before continuing")
      show_scary_paths_opt = SwitchSpec.new("-s", "--scary-paths", "if set prints scary paths and exits")
      local_only_opt = SwitchSpec.new("-L", "--local-only", "if set I will not check apibuilder.io or github to check for existing conflicting projects. I will also not create a new apibuilder porject or github repository")
      add_spring_maven_opt = SwitchSpec.new("-M", "--spring-maven", "if set I will add in a working pom.xml and a generic src directory tree for building this project using maven and spring")
      group_id_opt = OptionSpec.new("-g", "--group-id GROUPID", String, "The group id used for build configurations. IE Maven or Gradle. Required when using switches that enable build template generation.")
      add_spring_gradle_opt = SwitchSpec.new("-G", "--spring-gradle", "if set I will add in a working gradlew, gradle build, and a generic src directory tree for building this project using gradle and spring")

      @force = false
      @clean = false
      @debug = false
      @local_only = false
      @github_token_file = nil
      @add_spring_maven = false
      @add_spring_maven = false
      @group_id = nil

      @apibuilder_profile = nil
      @apibuilder_token = nil
      @project_package = nil

      optionParser = OptionParser.new do |opts|
        opts.banner = "Usage: #{File.basename(script_path)} [options]"
        opts.on(org_opt.short, org_opt.long, org_opt.type, org_opt.description) do |v|
          @organization = v
        end
        opts.on(app_opt.short, app_opt.long, app_opt.type, app_opt.description) do |v|
          @application = v
        end
        opts.on(version_opt.short, version_opt.long, version_opt.type, version_opt.description) do |v|
          @version = v
        end
        opts.on(path_opt.short, path_opt.long, path_opt.type, path_opt.description) do |v|
          @target_directory = v
        end

        opts.on(github_token_file_opt.short, github_token_file_opt.long, github_token_file_opt.type, github_token_file_opt.description) do |v|
          @github_token_file = v
        end

        opts.on(debug_opt.short, debug_opt.long, debug_opt.description) do |v|
          @debug = true
        end

        opts.on(force_opt.short, force_opt.long, force_opt.description) do |v|
          @force = true
        end
        opts.on(clean_opt.short, clean_opt.long, clean_opt.description) do |v|
          @clean = true
        end

        opts.on(local_only_opt.short, local_only_opt.long, local_only_opt.description) do |v|
          @local_only = true
        end
        opts.on("-h", "--help", "Prints this help") do
          puts opts
          exit
        end
        opts.on(show_scary_paths_opt.short, show_scary_paths_opt.long, show_scary_paths_opt.description) do
          puts "Scary paths are as follows"
          ScaryPaths.each { |pattern| puts pattern.source }
          exit
        end
        ## All the build system template configs.
        opts.on(add_spring_maven_opt.short, add_spring_maven_opt.long, add_spring_maven_opt.description) do |v|
          @add_spring_maven = true
        end
        ## All the build system template configs.
        opts.on(add_spring_gradle_opt.short, add_spring_gradle_opt.long, add_spring_gradle_opt.description) do |v|
          @add_spring_gradle = true;
        end
        opts.on(group_id_opt.short, group_id_opt.long, group_id_opt.type, group_id_opt.description) do |v|
          @group_id = v
        end

      end

      begin
        optionParser.parse!(options)
      rescue OptionParser::MissingArgument => e
        logAndFail optionParser, "Missing argument for option #{e.args[0]}"
      end

      logAndFail(optionParser, reqArgMessage(app_opt)) if @application == nil
      logAndFail(optionParser, reqArgMessage(org_opt)) if @organization == nil
      logAndFail(optionParser, reqArgMessage(version_opt)) if @version == nil
      logAndFail(optionParser, reqArgMessage(path_opt)) if @target_directory == nil
      # logAndFail(optionParser, reqArgMessage(github_token_file_opt)) if @github_token_file == nil

      @project_name = "#{@organization}.api.#{@application}"

      @target_directory = File.absolute_path(File.expand_path(@target_directory))
      @project_base_dir = File.absolute_path(File.expand_path("#{@target_directory}/#{@project_name}"))

      if (@local_only == false)
        # Makes the token file argument required if not in local only mode.
        logAndFail(optionParser, "You must pass a github token file if not in local only mode.") if (@github_token_file == nil)
        @github_token_file = File.absolute_path(File.expand_path("#{@github_token_file}"))
        logAndFail(optionParser, "The token file at #{@github_token_file} does not exist.") if !File.exist?(@github_token_file)
        @github_token = IO.read(@github_token_file)
        logAndFail(optionParser, "The token file at #{@github_token_file} is empty.") if @github_token == nil
        @apibuilder_profile = ApibuilderCli::Util.read_non_empty_string(ENV['PROFILE'])
        @apibuilder_token = ApibuilderCli::Util.read_non_empty_string(ENV['APIBUILDER_TOKEN']) || ApibuilderCli::Util.read_non_empty_string(ENV['APIDOC_TOKEN'])
      end

      if (@add_spring_maven || @add_spring_gradle) # We are going to template out a spring maven build system
        if (@local_only == false && @group_id == nil)
          #Try and use the apibuilder client to get the organizations namespace.
          logAndFail(optionParser, "You must pass a group_id if attempting to use build templates. In the future if not in local only mode I will use the organizations namespace as the group id.") if (@group_id == nil)
        end
        # puts(@application)
        @project_package = "#{@group_id}.#{@application.split(/[\-\_\.]/).join(".")}"
        # puts(@project_package)

        logAndFail(optionParser, "You must pass a group_id if attempting to use build templates and in local only mode. If not in local only mode I will use the organizations namespace as the group id.") if (@group_id == nil)
      end

      if (@add_spring_maven && @add_spring_gradle)
        logAndFail(optionParser, "The --spring-maven and --spring-gradle switch arguments are mutually exclusive. Pick one")
      end

    end
  end

end


