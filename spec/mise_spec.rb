require 'mise_en_place/mise'

RSpec.describe MiseEnPlace::Mise do

  before(:each) do
    @project_name = "test"
    @pwd = Dir.pwd
    @subject = MiseEnPlace::Mise.new({:project_name => @project_name})
  end

  after(:each) do
    FileUtils.remove_dir(File.join(@pwd, @project_name))
  end

  context "initialize" do

    it "creates a top level directory with given project name" do
      expect(File.exist? File.join(@pwd, @project_name)).to be(true)
    end

    it "stops execution if folder already exists and user wishes not to overwrite" do
      allow_any_instance_of(MiseEnPlace::Mise).to receive(:ask_to_overwrite).and_return("n")
      expect { MiseEnPlace::Mise.new({:project_name => @project_name}) }.to raise_exception(SystemExit)
    end

    it "reads a config file that is specified with -c" do
      allow_any_instance_of(MiseEnPlace::Mise).to receive(:ask_to_overwrite).and_return("y")
      yml_file = Pathname "given_config.yml"
      allow_any_instance_of(MiseEnPlace::Mise).to receive(:options).and_return(OpenStruct.new(:config => yml_file))
      @subject = MiseEnPlace::Mise.new(:project_name => @project_name)
      expect(@subject.options.config).to eq(yml_file)
    end
  end

  context "read YAML" do
    it "will exit when no YAML file exists" do
      allow(@subject).to receive(:exit)
      expect(@subject).to receive(:exit)
      @subject.fetch_yaml("file_does_not_exist")
    end

    it 'will exit when no matching project type exists' do
      allow(@subject).to receive(:exit)
      allow(YAML).to receive(:load_file).and_return(nil)
      expect(@subject).to receive(:exit)
      @subject.fetch_yaml
    end

    context "finds a YAML file" do
      it "will read a YAML file and return a matching hash when given a filename" do
        ensure_yaml_file
        @dir = Pathname(File.dirname(__FILE__))
        @loaded_yaml = @subject.fetch_yaml("#{@dir.parent}/sample_config.yml")
        expect(@loaded_yaml).to eq(
          yaml_as_ruby.first["default"]
        )
      end
    end

    it "will find a YAML file in the home directory when no filename is provided" do
      create_home_dir_yaml
      stub_const("MiseEnPlace::Mise::CONFIG_FILENAME", ".project_config_sample.yml")
      @loaded_yaml = @subject.fetch_yaml
      expect(@loaded_yaml).to eq(yaml_as_ruby.first["default"])
      @filepath = Pathname(File.expand_path('~')) + ".project_config_sample.yml"
      FileUtils.rm(@filepath)
    end

    it "will create a YAML file in the home directory if none is found and user agrees" do
      file_path = Pathname(File.expand_path('~')) + ".file_does_not_exist.yml"
      stub_const("MiseEnPlace::Mise::CONFIG_PATH", file_path)
      stub_const("MiseEnPlace::Mise::CONFIG_FILENAME", ".file_does_not_exist.yml")
      allow_any_instance_of(MiseEnPlace::Mise).to receive(:ask_to_build_config).and_return("y")
      @loaded_yaml = @subject.fetch_yaml
      expect(File.exist? file_path).to be(true)
      FileUtils.rm(file_path)
    end

    it "will exit if user does not agree to create a config file" do
      allow(@subject).to receive(:ask_to_build_config).and_return("n")
      stub_const("MiseEnPlace::Mise::CONFIG_FILENAME", ".file_does_not_exist.yml")
      allow(@subject).to receive(:exit)
      expect(@subject).to receive(:exit)
      @subject.fetch_yaml
    end

    it "will return yaml from a given project type" do
      allow_any_instance_of(MiseEnPlace::Mise).to receive(:options).and_return(OpenStruct.new({"project_type" => "html"}))
      ensure_yaml_file
      allow_any_instance_of(MiseEnPlace::Mise).to receive(:ask_to_overwrite).and_return("y")
      @subject = MiseEnPlace::Mise.new :project_name => @project_name
      @dir = Pathname(File.dirname(__FILE__))
      @loaded_yaml = @subject.fetch_yaml("#{@dir.parent}/sample_config.yml")
      expect(@loaded_yaml).to eq(yaml_as_ruby.first["html"])
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
    [{"default"=>[{"js"=>["index.js", {"subfolder"=>["something.js"]}]}, "index.html", "images"],
      "html" => ["index.html", "contact.html"]
      }]
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
