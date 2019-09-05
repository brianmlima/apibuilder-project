module ScaryPaths

  Paths = [
      /^\/$/,
      /^\/etc$/,
      /^\/root$/,
      /^\/usr$/,
      /^\/var$/,
      /^#{Regexp.quote(File.expand_path("~/../"))}$/,
      /^#{Regexp.quote(File.absolute_path(File.expand_path("~/")))}$/
  ]


  class Checks
    def Checks.failOnScaryPath(*paths)
      paths.each do |path|
        scaryPath = Paths.any? {|pattern| pattern.match?(path)}
        if scaryPath
          puts "Cowardly refusing to operate on the scary path of #{path}"
          puts "Scary paths are as follows"
          Paths.each {|pattern| puts pattern.source}
          exit false
        end
      end
    end
  end
end