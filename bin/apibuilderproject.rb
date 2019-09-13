#!/usr/bin/env ruby

version_used_for_gem_home = RUBY_VERSION.gsub /\.\d+$/, '.0'
ENV['GEM_HOME'] = "~.gem/ruby/#{version_used_for_gem_home}/"
# require 'bundler/inline'
require 'bundler/inline'
require 'bundler'
require 'json'
# Bundler.configure
gemfile(false) do
  source "https://rubygems.org"
  gem "octokit", "~> 4.0"
  gem 'git', '~> 1.5'
end

load File.join(File.dirname(__FILE__), '../src/apibuilder-project.rb')

private def logAndFail(message)
  puts message
  exit(false)
end

appConfig = ApibuilderProject::AppConfig.new(ARGV, __FILE__)

# debug = appConfig.debug

@debug = appConfig.debug

@integration_manager = ApibuilderProject::IntegrationManager.new(:app_config => appConfig)

@do_integrations = @integration_manager.do_integrations
@use_git = @integration_manager.use_git
@use_github = @integration_manager.use_github
@use_apibuilder_io = @integration_manager.use_apibuilder_io

# If we are using integrations we have to check them to make sure we are not accidently overwriting
# existing repositories / applications and that the application organization exists
# This should also fail the app if the required configurations are not available or are invalid
if @do_integrations
  if @use_github && @integration_manager.github_repo_exists
    puts "The derrived project name #{appConfig.project_name} already exists, perhaps you should choose another application name. Cowardly refusing to continue"
    exit false
  end
  if @use_apibuilder_io
    if @integration_manager.apibuilder_org_exists
      puts "Confirmed Organization #{appConfig.organization} exists" if @debug
    else
      puts "Apinuilder Organization #{appConfig.organization} does not exist. Cowardly failing."
      exit false
    end
    if @integration_manager.apibuilder_app_exists
      puts "WARNING ApiBuilder Application #{appConfig.application} already exists in organization #{appConfig.organization}. Cowardly failing"
      exit false
    else
      puts "Confirmed Application #{appConfig.application} does not exist in organization #{appConfig.organization}" if @debug
    end
  end
end

if @debug
  puts "organization=#{appConfig.organization}"
  puts "application=#{appConfig.application}"
  puts "version=#{appConfig.version}"
  puts "target_directory=#{appConfig.target_directory}"
  puts "force=#{appConfig.force}"
  puts "clean=#{appConfig.clean}"
  puts "project_base_dir=#{appConfig.project_base_dir}"
end

ScaryPaths::PathChecks.failOnScaryPath(appConfig.target_directory, appConfig.project_base_dir)


# if the target dir does not exist create it if force is set otherwise exit
target_directory = appConfig.target_directory
if !Dir.exist?(target_directory)
  if appConfig.force
    FileUtils.mkdir_p target_directory
  else
    logAndFail("destination #{target_directory} does not exits. Use force flag to force creation.")
  end
else
  puts "destination #{target_directory} exists"
end

project_dir = appConfig.project_base_dir
if !Dir.exist?(project_dir)
  puts "creating #{project_dir} "
  FileUtils.mkdir_p project_dir
else
  if appConfig.clean
    FileUtils.rm_rf("#{project_dir}/*")
  else
    logAndFail("project directory at #{project_dir} is not empty. Use clean flag to clean contents before templating.")
  end
end

ApibuilderProject::GeneratorConfig.write(
    script_name: __FILE__,
    organization: appConfig.organization,
    application: appConfig.application,
    version: appConfig.version,
    force: appConfig.force,
    clean: appConfig.clean,
    project_base_dir: appConfig.project_base_dir
)

ApibuilderProject::ApiJson.write(
    application: appConfig.application,
    project_base_dir: appConfig.project_base_dir
)


ApibuilderProject::ProjectConfig.write(
    organization: appConfig.organization,
    application: appConfig.application,
    version: appConfig.version,
    project_base_dir: appConfig.project_base_dir
)

ApibuilderProject::GitIgnore.write(
    :project_base_dir => appConfig.project_base_dir,
    :lines => ApibuilderProject::GitIgnore.default_lines
)

ApibuilderProject::ReadMe.write(
    organization: appConfig.organization,
    application: appConfig.application,
    version: appConfig.version,
    project_base_dir: appConfig.project_base_dir
)

ApibuilderProject::StaticFiles.copyFiles(:project_base_dir => appConfig.project_base_dir)

if @do_integrations
  if @use_github
    @integration_manager.github_repo_create
  end
  if @use_git
    @integration_manager.git_init
    @integration_manager.git_add
    @integration_manager.git_commit("Initial Automated Commit from #{File.basename(__FILE__)}")

    if @use_github
      @integration_manager.git_add_remote(@integration_manager.github_remote)
      @integration_manager.git_push
    end
  end
  if @use_apibuilder_io
    @integration_manager.apibuilder_create_application
  end
end
