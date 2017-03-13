require 'parser'

RSpec.describe Parser do

  context 'config' do
    before(:each) do
      @file_path = "/path/to/config/file.yml"
    end

    it 'should set a path for config file with -c' do
      @args = ["-c", @file_path]
      @options = Parser.parse(@args)
      expect(@options.config).to eq(Pathname(@file_path))
    end

    it 'should set a path for config file with --config' do
      @args = ["--config", @file_path]
      @options = Parser.parse(@args)
      expect(@options.config).to eq(Pathname(@file_path))
    end
  end

  context 'project type' do
    before(:each) do
      @project_type = "node"
    end

    it 'should set the project type with -p' do
      @args = ['-p', @project_type]
      @options = Parser.parse(@args)
      expect(@options.project_type).to eq(@project_type)
    end

    it 'should set the project type with --project' do
      @args = ['--project', @project_type]
      @options = Parser.parse(@args)
      expect(@options.project_type).to eq(@project_type)
    end
  end

end
