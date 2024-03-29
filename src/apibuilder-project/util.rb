#Based on https://github.com/apicollective/apibuilder-cli/blob/master/src/apibuilder-cli/util.rb

module ApibuilderProject

  module Util

    StaticResource = Struct.new(:loc, :dest, :is_dir)

    def Util.copyFiles(staticResources)
      staticResources.each do |v|
        if v.is_dir == true
          FileUtils.cp_r v.loc, v.dest
        else
          FileUtils.cp v.loc, v.dest
        end
      end
    end

    def Util.file_join(*args)
      args.select! { |s| s.to_s.strip != "" }
      File.join(*args)
    end

    # Writes contents to a temp file, returning the path
    def Util.write_to_temp_file(contents)
      tmp = Tempfile.new('apibuilder-project')
      Util.write_to_file(tmp.path, contents)
    end

    # Writes contents to the file at the specified path, returning the path
    def Util.write_to_file(path, contents)
      Preconditions.assert_class(path, String)
      File.open(path, "w") do |out|
        out << contents
      end
      path
    end

    def Util.mkdirs(target_directory)
      if !Dir.exist?(target_directory)
        FileUtils.mkdir_p target_directory
      end
    end

    # Returns the trimmed value if not empty. If empty (or nil) returns nil
    def Util.read_non_empty_string(value)
      trimmed = value.to_s.strip
      if trimmed == ""
        nil
      else
        trimmed
      end
    end

    # Returns the value only if a valid integer
    def Util.read_non_empty_integer(value)
      trimmed = Util.read_non_empty_string(value)
      if trimmed && trimmed.to_i.to_s == trimmed
        trimmed.to_i
      else
        nil
      end
    end

    # Returns first 3 characters and last 4 characters only
    def Util.mask(value)
      if value.size > 15
        letters = value.split("")
        letters[0, 3].join("") + "-XXXX-" + letters[letters.size - 4, letters.size].join("")
      else
        "XXX-XXXX-XXXX"
      end
    end

    def Util.absolute_path(path)
      File.absolute_path(File.expand_path(path))
    end
  end

end
