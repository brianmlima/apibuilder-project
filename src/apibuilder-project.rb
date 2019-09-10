#Based on https://github.com/apicollective/apibuilder-cli/blob/master/src/apibuilder-cli.rb
require 'yaml'
require 'tempfile'

dir = File.dirname(__FILE__)
########################################################################################################################
# Load Application code
lib_dir = File.join(dir, "apibuilder-project")

load File.join(lib_dir, 'preconditions.rb')
load File.join(lib_dir, 'util.rb')
load File.join(lib_dir, 'app_config.rb')
load File.join(lib_dir, 'scary_paths.rb')
load File.join(lib_dir, 'git.rb')
load File.join(lib_dir, 'templates.rb')

########################################################################################################################
# Load Apibuilder.io latest API
apibuilder_cli_dir = File.join(dir, "apibuilder-cli")

load File.join(apibuilder_cli_dir, 'apicollective_apibuilder_api_v0_client.rb')
load File.join(apibuilder_cli_dir, 'apicollective_apibuilder_common_v0_client.rb')
load File.join(apibuilder_cli_dir, 'apicollective_apibuilder_generator_v0_client.rb')
load File.join(apibuilder_cli_dir, 'apicollective_apibuilder_spec_v0_client.rb')
load File.join(apibuilder_cli_dir, 'config.rb')
load File.join(apibuilder_cli_dir, 'preconditions.rb')
load File.join(apibuilder_cli_dir, 'util.rb')
