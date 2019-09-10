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
                :local_only

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
      app_opt = OptionSpec.new("-a", "--application APPLICATION", String, "(Required) the apibuilder application key")
      version_opt = OptionSpec.new("-v", "--version VERSION", String, "(Required) the application version")
      path_opt = OptionSpec.new("-d", "--destination DESTINATION", String, "(Required) the destination directory where the template will be rendered")
      force_opt = SwitchSpec.new("-f", "--force", "if set the destination directory will be created if it does not exist and existing files will be overwritten")
      clean_opt = SwitchSpec.new("-c", "--clean", "if set and the project destination directory exists all contents will be deleted before continuing")
      debug_opt = SwitchSpec.new("--debug", "", "if set and the project destination directory exists all contents will be deleted before continuing")
      show_scary_paths_opt = SwitchSpec.new("-s", "--scary-paths", "if set prints scary paths and exits")
      local_only_opt = SwitchSpec.new("-L", "--local-only", "if set I will not check apibuilder.io or github to check for existing conflicting projects. I will also not create a new apibuilder porject or github repository")


      @force = false
      @clean = false
      @debug = false
      @local_only = false


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
          ScaryPaths.each {|pattern| puts pattern.source}
          exit
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
      logAndFail(optionParser, reqArgMessage(github_token_file_opt)) if @github_token_file == nil

      @project_name = "#{@organization}.api.#{@application}"

      @target_directory = File.absolute_path(File.expand_path(@target_directory))
      @project_base_dir = File.absolute_path(File.expand_path("#{@target_directory}/#{@project_name}"))

      @github_token_file = File.absolute_path(File.expand_path("#{@github_token_file}"))
      logAndFail(optionParser, "The token file at #{@github_token_file} does not exist.") if !File.exist?(@github_token_file)
      @github_token = IO.read(@github_token_file)
      logAndFail(optionParser, "The token file at #{@github_token_file} is empty.") if @github_token == nil

      @apibuilder_profile = ApibuilderCli::Util.read_non_empty_string(ENV['PROFILE'])
      @apibuilder_token = ApibuilderCli::Util.read_non_empty_string(ENV['APIBUILDER_TOKEN']) || ApibuilderCli::Util.read_non_empty_string(ENV['APIDOC_TOKEN'])

    end
  end

end


