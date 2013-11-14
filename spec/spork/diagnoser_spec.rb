require 'spec_helper'

describe Spork::Diagnoser do
  after(:each) do
    Spork::Diagnoser.remove_hook!
    Spork::Diagnoser.loaded_files.clear
  end

  def run_simulation(directory, filename = nil, contents = nil, &block)
    FileUtils.mkdir_p(directory)
    Dir.chdir(directory) do
      if filename
        File.open(filename, 'wb') { |f| f << contents }
        Spork::Diagnoser.install_hook!
        require "./#{filename}"
      end
      yield if block_given?
    end
  end

  it "installs it's hook and tells you when files have been loaded" do
    run_simulation(SPEC_TMP_DIR, 'my_awesome_library_include.rb', '1 + 5')
    expect(Spork::Diagnoser.loaded_files.keys).to include_a_string_like('my_awesome_library_include')
  end

  it 'excludes files outside of Dir.pwd' do
    run_simulation(SPEC_TMP_DIR + '/project_root', '../external_dependency.rb', '1 + 5')
    expect(Spork::Diagnoser.loaded_files.keys).to_not include_a_string_like('external_dependency')
  end

  it "excludes files outside of Dir.pwd but in ruby's include path" do
    directory = SPEC_TMP_DIR + '/project_root'
    external_dependency_dir = SPEC_TMP_DIR + '/external_dependency'
    $: << external_dependency_dir
    FileUtils.mkdir_p(directory)
    FileUtils.mkdir_p(external_dependency_dir)
    Dir.chdir(directory) do
      File.open(external_dependency_dir + '/the_most_awesome_external_dependency_ever.rb', 'wb') { |f| f << 'funtimes = true' }
      Spork::Diagnoser.install_hook!
      require 'the_most_awesome_external_dependency_ever'
    end

    expect(Spork::Diagnoser.loaded_files.keys).to_not include_a_string_like('the_most_awesome_external_dependency_ever')
    $:.pop
  end

  it "expands files to their fully their fully qualified path" do
    directory = SPEC_TMP_DIR + '/project_root'
    lib_directory = directory + '/lib'
    $: << lib_directory
    FileUtils.mkdir_p(lib_directory)
    Dir.chdir(directory) do
      File.open(lib_directory + "/the_most_awesome_lib_file_ever.rb", "wb") { |f| f << "funtimes = true" }
      Spork::Diagnoser.install_hook!
      require 'the_most_awesome_lib_file_ever'
    end

    expect(Spork::Diagnoser.loaded_files.keys).to include_a_string_like('lib/the_most_awesome_lib_file_ever')
    $:.pop
  end

  it "can tell the difference between a folder in the project path and a file in an external path" do
    directory = SPEC_TMP_DIR + '/project_root'
    external_dependency_dir = SPEC_TMP_DIR + '/external_dependency'
    $: << external_dependency_dir
    FileUtils.mkdir_p(directory)
    FileUtils.mkdir_p(external_dependency_dir)
    Dir.chdir(directory) do
      FileUtils.mkdir_p(directory + '/a_popular_folder_name')
      File.open(external_dependency_dir + '/a_popular_folder_name.rb', 'wb') { |f| f << 'funtimes = true' }
      Spork::Diagnoser.install_hook!
      require 'a_popular_folder_name'
    end

    expect(Spork::Diagnoser.loaded_files.keys).to_not include_a_string_like('a_popular_folder_name')
    $:.pop
  end

  it "filters backtrace beyond the last line matching the entry point" do
    Spork::Diagnoser.install_hook!("test_filter/environment.rb")
    create_file("test_filter/environment.rb", "require './test_filter/app.rb'")
    create_file("test_filter/app.rb", "require './test_filter/my_model.rb'")
    create_file("test_filter/my_model.rb", "'my model here'")
    in_current_dir do
      require './test_filter/environment.rb'
    end
    f = Spork::Diagnoser.loaded_files
    expect(f[f.keys.grep(/app.rb/).first].last).to include('test_filter/environment.rb')
    expect(f[f.keys.grep(/my_model.rb/).first].last).to include('test_filter/environment.rb')
    expect(f[f.keys.grep(/environment.rb/).first]).to eq []
  end

  describe ".output_results" do
    it "outputs the results relative to the current directory" do
      Spork::Diagnoser.loaded_files["/project_path/lib/file.rb"] = ["/project_path/lib/parent_file.rb:35"]
      Dir.stub!(:pwd).and_return("/project_path")
      out = StringIO.new
      Spork::Diagnoser.output_results(out)
      expect(out.string).to match( %r([^/]lib/file.rb) )
      expect(out.string).to match( %r([^/]lib/parent_file.rb) )
      expect(out.string).to_not include("/project_path/")
    end
  end
end
