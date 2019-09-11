module ScaryPaths

  ScaryPaths = [
      /^\/$/,
      /^\/etc$/,
      /^\/root$/,
      /^\/usr$/,
      /^\/var$/,
      /^#{Regexp.quote(File.expand_path("~/../"))}$/,
      /^#{Regexp.quote(File.absolute_path(File.expand_path("~/")))}$/
  ]

  class PathChecks
    def PathChecks.failOnScaryPath(*paths)
      paths.each do |path|
        scaryPath = ScaryPaths.any? {|pattern| pattern.match?(path)}
        if scaryPath
          puts "Cowardly refusing to operate on the scary path of #{path}"
          puts "Scary paths are as follows"
          ScaryPaths.each {|pattern| puts pattern.source}
          exit false
        end
      end
    end
  end
end