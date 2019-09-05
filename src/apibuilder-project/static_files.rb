require 'fileutils'

module ApibuilderProject

  StaticResource = Struct.new(:loc, :dest, :is_dir)

  class StaticFiles

    def StaticFiles.copyFiles(project_base_dir:)

      # puts "called"
      staticResources = [
          StaticResource.new(
              Util.absolute_path("#{File.dirname(__FILE__)}/../templates/bin"),
              Util.absolute_path("#{project_base_dir}"),
              true)
      ]
      staticResources.each do |v|
        if v.is_dir == true
          FileUtils.cp_r v.loc, v.dest
        end
      end
    end
  end
end

