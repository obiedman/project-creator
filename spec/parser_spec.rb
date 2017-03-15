require 'mise_en_place/parser'

RSpec.describe MiseEnPlace::Parser do

  before(:each) do
    # suppress terminal output
    allow(MiseEnPlace::Parser).to receive(:puts)
  end

  context 'project name' do
    it 'sets a project name with the given name' do
      @project_name = 'mise_en_place'
      @args = [@project_name]
      @options = MiseEnPlace::Parser.parse(@args)
      expect(@options.project_name).to eq(@project_name)
    end

    context 'failure' do
      it 'exits if no project name is given' do
        allow(MiseEnPlace::Parser).to receive(:exit)
        expect(MiseEnPlace::Parser).to receive(:exit)
        MiseEnPlace::Parser.parse []
      end

      MiseEnPlace::Parser::FLAGS.each do |flag|
        it "exits because of #{flag}" do
          @project_name = flag
          @args = [@project_name, "option"]
          allow(MiseEnPlace::Parser).to receive(:exit)
          expect(MiseEnPlace::Parser).to receive(:exit)
          MiseEnPlace::Parser.parse @args
        end
      end
    end
  end

  context 'config' do
    before(:each) do
      @file_path = "/path/to/config/file.yml"
    end

    it 'should set a path for config file with -c' do
      @args = ['mise_en_place', "-c", @file_path]
      @options = MiseEnPlace::Parser.parse(@args)
      expect(@options.config).to eq(Pathname(@file_path))
    end

    it 'should set a path for config file with --config' do
      @args = ['mise_en_place', "--config", @file_path]
      @options = MiseEnPlace::Parser.parse(@args)
      expect(@options.config).to eq(Pathname(@file_path))
    end
  end

  context 'project type' do
    before(:each) do
      @project_type = "node"
    end

    it 'should set the project type with -p' do
      @args = ['mise_en_place', '-p', @project_type]
      @options = MiseEnPlace::Parser.parse(@args)
      expect(@options.project_type).to eq(@project_type)
    end

    it 'should set the project type with --project' do
      @args = ['mise_en_place', '--project', @project_type]
      @options = MiseEnPlace::Parser.parse(@args)
      expect(@options.project_type).to eq(@project_type)
    end
  end

end
