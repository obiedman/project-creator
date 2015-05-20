require 'fileutils'
require 'yaml'
require 'pathname'
require 'ostruct'
require 'optparse'

class ProjectCreator
  VERSION = '0.1.1'

  def initialize(project_name)
    @top_level_dir = Pathname(project_name)
    FileUtils.mkdir_p(@top_level_dir)
  end

  def fetch_yaml(config_path)
    begin
      YAML.load_file(config_path)
    rescue Errno::ENOENT
      puts "\
      Oops! It looks like you're missing a config file in the expected path. Make sure it exists, specify a path with the --config option, 
      or change the default path in self.parse"
      exit
    end
  end

  def build_file_structure(yaml, path=@top_level_dir)
    path = Pathname(path)
    yaml.each do |element|
      if element.is_a?(Hash)
        element.values.each do |thing|
          build_file_structure(thing, path + element.keys.first)
        end
      else
        # cast to Array to avoid type checking between Array or String
        Array[element].each do |file_or_dir|
          create_file_or_dir(file_or_dir, path)
        end
      end
    end
  end

  def self.parse(args)
    options = OpenStruct.new
    options.config = Pathname(ENV['HOME']) + ".project_creator_config.yml"
    opt_parser = OptionParser.new do |opts|
      opts.banner = "Usage: ProjectCreator [options]"
      opts.separator ""
      opts.separator "Specific Options:"

      opts.on("-c", "--config PATH", "Path to your config file") do |path|
        options.config = Pathname(path)
      end

      opts.on("-h", "--help", "Show this message") do
        puts opts
        exit
      end

      opts.on_tail("-v", "--version", "Show Version number") do
        puts VERSION
        exit
      end

    end
    opt_parser.parse!(args)
    options
  end

  private

  def create_file_or_dir(file_or_dir, path)
    full_path = Pathname(path + file_or_dir)
    if is_dir?(file_or_dir)
      FileUtils.mkdir_p(full_path)
    else
      FileUtils.mkdir_p(path)
      FileUtils.touch(full_path)
    end
  end

  def is_dir?(file_or_dir)
    Pathname(file_or_dir).extname == ""
  end

end

project_name = ARGV.shift
options = ProjectCreator.parse(ARGV)
creator = ProjectCreator.new(project_name)
creator.build_file_structure(creator.fetch_yaml(options.config))