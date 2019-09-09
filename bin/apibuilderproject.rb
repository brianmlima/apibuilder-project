#!/usr/bin/env ruby

version_used_for_gem_home = RUBY_VERSION.gsub /\.\d+$/, '.0'
ENV['GEM_HOME'] = "~.gem/ruby/#{version_used_for_gem_home}/"
# require 'bundler/inline'
require 'bundler/inline'
require 'bundler'
require 'json'
# Bundler.configure
gemfile(true) do
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

debug = appConfig.debug

apibuilderClient = ApibuilderCli::Config.client_from_profile(:profile => appConfig.apibuilder_profile, :token => appConfig.apibuilder_token)
github = ApibuilderProject::GithubProject.new(:access_token => appConfig.github_token, :project_name => appConfig.project_name)

#############
# Check to make sure the app and repo does not already exist and make sure the organization exists.
#############


if github.repo_exists
  puts "The derrived project name #{appConfig.project_name} already exists, perhaps you should choose another application name. Cowardly refusing to continue"
  exit false
end

remoteOrg = apibuilderClient.organizations.get.find {|org| org.name == appConfig.organization}
remoteApp = apibuilderClient.applications.get(remoteOrg.key).find {|app| app.name == appConfig.application}

# org_exists = v.any? {|org| org.name == appConfig.organization}
if remoteOrg
  puts "Confirmed Organization #{appConfig.organization} exists" if debug
else
  puts "Apinuilder Organization #{appConfig.organization} does not exist. Cowardly failing."
  exit false
end

if remoteApp
  puts "WARNING ApiBuilder Application #{appConfig.application} already exists in organization #{appConfig.organization}. Cowardly failing"
  exit false
else
  puts "Confirmed Application #{appConfig.application} does not exist in organization #{appConfig.organization}" if debug
end


if appConfig.debug
  puts "organization=#{appConfig.organization}"
  puts "application=#{appConfig.application}"
  puts "version=#{appConfig.version}"
  puts "target_directory=#{appConfig.target_directory}"
  puts "force=#{appConfig.force}"
  puts "clean=#{appConfig.clean}"
  puts "project_base_dir=#{appConfig.project_base_dir}"
end

ScaryPaths::Checks.failOnScaryPath(appConfig.target_directory, appConfig.project_base_dir)


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

generatorConfig = ApibuilderProject::GeneratorConfig.new(
    script_name: __FILE__,
    organization: appConfig.organization,
    application: appConfig.application,
    version: appConfig.version,
    force: appConfig.force,
    clean: appConfig.clean,
    project_base_dir: appConfig.project_base_dir
)

apiJon = ApibuilderProject::ApiJson.new(
    application: appConfig.application,
    project_base_dir: appConfig.project_base_dir
)


projectConfig = ApibuilderProject::ProjectConfig.new(
    organization: appConfig.organization,
    application: appConfig.application,
    version: appConfig.version,
    project_base_dir: appConfig.project_base_dir
)

ApibuilderProject::StaticFiles.copyFiles(:project_base_dir => appConfig.project_base_dir)

github.create

gitProject = ApibuilderProject::GitProject.new(
    organization: appConfig.organization,
    application: appConfig.application,
    version: appConfig.version,
    project_base_dir: appConfig.project_base_dir,
    git_remote: github.remote
)

application_form = Io::Apibuilder::Api::V0::Models::ApplicationForm.new(
    :name => appConfig.application,
    :key => appConfig.application,
    :description => "",
    :visibility => Io::Apibuilder::Api::V0::Models::Visibility.organization
)

apibuilderClient.applications.post(remoteOrg.key, application_form)


# puts "----------------"
# puts githubClient.user.login
# puts "----------------"
