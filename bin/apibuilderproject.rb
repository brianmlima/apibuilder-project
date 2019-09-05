#!/usr/bin/env ruby

version_used_for_gem_home = RUBY_VERSION.gsub /\.\d+$/, '.0'
ENV['GEM_HOME'] = "~.gem/ruby/#{version_used_for_gem_home}/"
# require 'bundler/inline'
require 'bundler/inline'
require 'bundler'
require 'json'
# Bundler.configure
gemfile(true) do
  gem "octokit", "~> 4.0"
end

load File.join(File.dirname(__FILE__), '../src/apibuilder-project.rb')

private def logAndFail(message)
  puts message
  exit(false)
end

appConfig = ApibuilderProject::AppConfig.new(ARGV, __FILE__)
apibuilderClient = ApibuilderCli::Config.client_from_profile(:profile => appConfig.apibuilder_profile, :token => appConfig.apibuilder_token)
github = ApibuilderProject::GithubProject.new(:access_token => appConfig.github_token, :project_name => appConfig.project_name)

# githubClient = Octokit::Client.new(:access_token => appConfig.github_token)
# gitUser = githubClient.user
# puts gitUser.inspect
#
# username = gitUser.inspect
#
# exit

# repo = Octokit::Repository.new(:user => username, :repo => appConfig.project_name)


if github.repo_exists
  puts "The derrived project name #{appConfig.project_name} already exists, perhaps you should choose another application name. Cowardly refusing to continue"
  exit false
end


puts "organization=#{appConfig.organization}"
puts "application=#{appConfig.application}"
puts "version=#{appConfig.version}"
puts "target_directory=#{appConfig.target_directory}"
puts "force=#{appConfig.force}"
puts "clean=#{appConfig.clean}"
puts "project_base_dir=#{appConfig.project_base_dir}"

ScaryPaths::Checks.failOnScaryPath(appConfig.target_directory, appConfig.project_base_dir)

v = apibuilderClient.organizations.get

remoteOrg = v.find {|org| org.name == appConfig.organization}

# org_exists = v.any? {|org| org.name == appConfig.organization}
if remoteOrg
  puts "Confirmed Organization #{appConfig.organization} exists"
end

v = apibuilderClient.applications.get(remoteOrg.key)
remoteApp = v.find {|app| app.name == appConfig.application}

if remoteApp
  puts "WARNING Application #{appConfig.application} already exists"
else
  puts "Confirmed Application #{appConfig.application} does not exist"
end


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


# puts "----------------"
# puts githubClient.user.login
# puts "----------------"
