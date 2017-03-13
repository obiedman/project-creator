#! /usr/bin/env ruby

require 'fileutils'
require 'yaml'
require 'pathname'
require 'ostruct'
require 'optparse'

module MiseEnPlace
  class Mise
    CONFIG_FILENAME = ".mise_en_place.yml"
    CONFIG_PATH = Pathname(File.expand_path('~')) + CONFIG_FILENAME

    def initialize(options={})
      @options = OpenStruct.new options
      @top_level_dir = Pathname(@options.project_name)
      request_and_overwrite if File.exist? @top_level_dir
      FileUtils.mkdir_p(@top_level_dir)
    end

    def options
      @options
    end

    def fetch_yaml(config_path=@options.config)
      begin
        full_yaml = YAML.load_file(config_path || find_config)
        unless full_yaml
          warn_no_project_type
          return
        end
        project_type = options.project_type || "default"
        full_yaml = full_yaml.reduce(:merge)[project_type]
        warn_no_project_type unless full_yaml
        return full_yaml
      rescue Errno::ENOENT, TypeError
        puts "\
        Please make sure a file named #{CONFIG_FILENAME} exists in your current directory or any of its parent directories or specify a path with the --config option"
        exit(false)
      end
    end

    def build_file_structure(yaml=fetch_yaml, path=@top_level_dir)
      path = Pathname(path)
      return unless yaml
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

    private

    def warn_no_project_type
      puts "\
      Could not find a valid yaml structure for your project. Make sure that a default structure or one for your project type exists in your config file. Try something like this:

      ---
      - default:
        - file_structure_here
      "
      puts "\
      - #{options.project_type}
        - file_structure_here" if options.project_type
      exit(false)
    end

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
      return request_and_build_config
    end

    def request_and_build_config
      input = ask_to_build_config
      if input == "" || input == "y"

        File.open(CONFIG_PATH, 'w') do |f|
          f.puts "---"
          f.puts "- default:"
        end unless File.exist? CONFIG_PATH
        puts "File created at #{CONFIG_PATH}. Add your desired project structure under default and run MiseEnPlace again."
        return CONFIG_PATH
      else

        return nil
      end
    end

    def ask_to_build_config
      puts "Could not find a config file. Would you like to create one now? [Y/n]"
      gets.chomp.downcase
    end

    def ask_to_overwrite
      puts "A folder with #{@top_level_dir} already exists. Overwrite?
      [y/N]"
      gets.chomp.downcase
    end

    def request_and_overwrite
      input = ask_to_overwrite
      if input == "y"
        return true
      else
        exit(false)
      end
    end

    def command_line_args
      ARGV
    end
  end
end
