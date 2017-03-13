class Parser

  def self.parse(args)
    options = OpenStruct.new
    opt_parser = OptionParser.new do |opts|
      opts.banner = "Usage: ProjectCreator [project_title] [options]"
      opts.separator ""
      opts.separator "Specific Options:"

      opts.on("-c", "--config PATH", "Path to your config file") do |path|
        options.config = Pathname(path)
      end

      opts.on("-h", "--help", "Show this message") do
        puts ""
        puts opts
        exit
      end

      opts.on("-p", "--project TYPE", "Specify a project type that matches a type in your config file") do |type|
        options.project_type = type
      end

      opts.on_tail("-v", "--version", "Show Version number") do
        puts VERSION
        exit
      end

    end
    opt_parser.parse!(args)
    options
  end

end
