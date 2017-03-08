#! /usr/bin/env ruby

require 'fileutils'
require 'yaml'
require 'pathname'
require 'ostruct'
require 'optparse'

class ProjectCreator
  VERSION = '0.2.0'
  CONFIG_FILENAME = ".project_creator_config.yml"
  CONFIG_PATH = Pathname(ENV['HOME']) + CONFIG_FILENAME

  def initialize(project_name)
    @top_level_dir = Pathname(project_name)
    FileUtils.mkdir_p(@top_level_dir)
    @options = ProjectCreator.parse(command_line_args)
  end

  def options
    @options
  end

  def fetch_yaml(config_path=@options.config)
    begin
      YAML.load_file(config_path || find_config)
    rescue Errno::ENOENT, TypeError
      puts "\
      Oops! Could not find a config file. Please make sure a file named .project_creator_config.yml exists in your current directory or any of its parent directories, specify a path with the --config option, or change the default path for this class."
      exit(false)
    end
  end

  def build_file_structure(yaml=fetch_yaml, path=@top_level_dir)
    path = Pathname(path)
    yaml.each do |file|
      if file.is_a?(Hash)
        file.values.each do |sub_file|
          build_file_structure(sub_file, path + file.keys.first)
        end
      else
        # cast to Array to avoid type checking between Array or String
        Array[file].each do |sub_file|
          create_file_or_dir(sub_file, path)
        end
      end
    end
  end

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

  def find_config
    path = Pathname(Dir.pwd)
    while path != Pathname("/")
      return path + CONFIG_FILENAME if File.exist? path + CONFIG_FILENAME
      path = path.parent
    end
  end

  def command_line_args
    ARGV
  end
end
