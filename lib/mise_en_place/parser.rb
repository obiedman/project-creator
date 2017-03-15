require 'ostruct'
require 'optparse'
require 'pathname'

module MiseEnPlace
  class Parser
    FLAGS = %w(-c --config -h --help -p --project)

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
      project_name = args.shift
      unless valid_project_name? project_name
        puts "Please specify a project name"
        exit(false)
      end
      options.project_name = project_name
      options
    end

    private

    def self.valid_project_name?(project_name)
      is_flag = FLAGS.include? project_name
      does_not_exist = (project_name == nil)
      return !(is_flag || does_not_exist)
    end
  end
end
