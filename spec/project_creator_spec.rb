require 'project_creator'

RSpec.describe ProjectCreator do

  before(:each) do
    @project_name = "test"
    @pwd = Dir.pwd
    @subject = ProjectCreator.new(@project_name)
  end

  after(:each) do
    FileUtils.remove_dir(File.join(@pwd, @project_name))
  end

  context "initialize" do

    it "creates a top level directory with given project name" do
      expect(File.exist? File.join(@pwd, @project_name)).to be(true)
    end

    it "reads a config file is specified with -c" do
      yml_file = "given_config.yml"
      allow_any_instance_of(ProjectCreator).to receive(:command_line_args).and_return(["-c", yml_file])
      @subject = ProjectCreator.new(@project_name)
      expect(@subject.options.config).to eq(Pathname(yml_file))
    end

    it "reads a config file that is specified with --config" do
      yml_file = "given_config.yml"
      allow_any_instance_of(ProjectCreator).to receive(:command_line_args).and_return(["--config", yml_file])
      @subject = ProjectCreator.new(@project_name)
      expect(@subject.options.config).to eq(Pathname(yml_file))
    end
  end

  context "read YAML" do
    it "will exit when no YAML file exists" do
      expect { @subject.fetch_yaml("file_does_not_exist") }.to raise_exception(SystemExit)
    end

    context "finds a YAML file" do
      it "will read a YAML file and return a matching hash when given a filename" do
        ensure_yaml_file
        @dir = Pathname(File.dirname(__FILE__))
        @loaded_yaml = @subject.fetch_yaml("#{@dir.parent}/sample_config.yml")
        expect(@loaded_yaml).to eq(
          yaml_as_ruby
        )
      end
    end

    it "will find a YAML file in the home directory when no filename is provided" do
      create_home_dir_yaml
      stub_const("ProjectCreator::CONFIG_FILENAME", ".project_config_sample.yml")
      @loaded_yaml = @subject.fetch_yaml
      expect(@loaded_yaml).to eq(yaml_as_ruby)
      @filepath = Pathname(File.expand_path('~')) + ".project_config_sample.yml"
      FileUtils.rm(@filepath)
    end

  end

  context "build_file_structure" do

    before do
      @top_level_dir = Pathname(@pwd) + @project_name
      @subject.build_file_structure(yaml_as_ruby)
    end
    it "should build files" do
      expect(File.exist? @top_level_dir + "index.html")
    end

    it "should build folders" do
      expect(File.exist? @top_level_dir + "js")
    end

    it "should build subfolders" do
      expect(File.exist? @top_level_dir + "js/subfolder")
    end

    it "should build files in subfolders" do
      expect(File.exist? @top_level_dir + "js/subfolder/something.js")
    end
  end

  private

  def yaml_as_ruby
    [{"js"=>["index.js", {"subfolder"=>["something.js"]}]}, "index.html", "images"]
  end

  def ensure_yaml_file
    @dir = Pathname(File.dirname(__FILE__)).parent
    @file = @dir + "sample_config.yml"
    File.open(@file, 'w') do |f|
      f.write YAML.dump(yaml_as_ruby)
    end unless File.exist? @file
  end

  def create_home_dir_yaml
    @dir = Pathname(File.expand_path('~'))
    @file = @dir + ".project_config_sample.yml"
    File.open(@file, 'w') do |f|
      f.write YAML.dump(yaml_as_ruby)
    end unless File.exist? @file
  end
end
