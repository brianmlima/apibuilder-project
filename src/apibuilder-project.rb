#Based on https://github.com/apicollective/apibuilder-cli/blob/master/src/apibuilder-cli.rb
require 'yaml'
require 'tempfile'

dir = File.dirname(__FILE__)
lib_dir = File.join(dir, "apibuilder-project")
apibuilder_cli_dir = File.join(dir, "apibuilder-cli")


load File.join(lib_dir, 'preconditions.rb')
load File.join(lib_dir, 'util.rb')
load File.join(lib_dir, 'args.rb')
load File.join(lib_dir, 'app_config.rb')
load File.join(lib_dir, 'scary_paths.rb')
load File.join(lib_dir, 'apibuilder_generator_config.rb')
load File.join(lib_dir, 'apibuilder_json.rb')
load File.join(lib_dir, 'github.rb')
load File.join(lib_dir, 'project_config.rb')
load File.join(lib_dir, 'static_files.rb')


load File.join(apibuilder_cli_dir, 'apicollective_apibuilder_api_v0_client.rb')
load File.join(apibuilder_cli_dir, 'apicollective_apibuilder_common_v0_client.rb')
load File.join(apibuilder_cli_dir, 'apicollective_apibuilder_generator_v0_client.rb')
load File.join(apibuilder_cli_dir, 'apicollective_apibuilder_spec_v0_client.rb')
load File.join(apibuilder_cli_dir, 'config.rb')
load File.join(apibuilder_cli_dir, 'preconditions.rb')
load File.join(apibuilder_cli_dir, 'util.rb')
