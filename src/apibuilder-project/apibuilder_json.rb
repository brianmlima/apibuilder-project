require 'erb'

module ApibuilderProject

  API_JSON_TEMPLATE_FILE_NAME = "api.erb"
  API_JSON_TEMPLATE_CONTENT = IO.read(File.absolute_path(File.expand_path("#{File.dirname(__FILE__)}/../templates/#{API_JSON_TEMPLATE_FILE_NAME}")))
  API_JSON_OUTPUT_FILE_NAME = "api.json"

  class ApiJson
    attr_reader :application, :project_base_dir

    def initialize(application:, project_base_dir:)
      @application = application
      @project_base_dir = project_base_dir
      @api_json_file = File.absolute_path(File.expand_path("#{@project_base_dir}/#{API_JSON_OUTPUT_FILE_NAME}"))
      createFile()
    end

    private def createFile()
      message = ERB.new(API_JSON_TEMPLATE_CONTENT, 0, "%<>")
      content = message.result(binding)
      IO.write(@api_json_file, content)
    end
  end

end
