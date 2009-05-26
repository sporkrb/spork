require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |s|
    s.name = %q{spork}
    s.version = "0.3"
    s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
    s.authors = ["Tim Harper"]
    s.date = %q{2009-05-20}
    s.description = %q{A forking Drb spec server}
    s.email = ["timcharper+spork@gmail.com"]
    s.executables = ["spork"]
    s.extra_rdoc_files = ["README.rdoc"]
    s.files = ["README.rdoc", "lib/spork", "lib/spork/spec_server.rb", "lib/spork.rb", "assets/bootstrap.rb"] 
    s.has_rdoc = true
    s.homepage = %q{http://github.com/timcharper/spork}
    s.rdoc_options = ["--main", "README.rdoc"]
    s.require_paths = ["lib"]
    s.rubyforge_project = %q{spork}
    s.rubygems_version = %q{1.3.1}
    s.summary = %{spork #{s.version}}
   # s is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end

rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: sudo gem install jeweler"
end

require 'spec/rake/spectask'
Spec::Rake::SpecTask.new(:spec) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.spec_files = FileList['spec/**/*_spec.rb']
end

Spec::Rake::SpecTask.new(:rcov) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov = true
end

begin
  require 'cucumber/rake/task'
  Cucumber::Rake::Task.new(:features)
rescue LoadError
  task :features do
    abort "Cucumber is not available. In order to run features, you must: sudo gem install cucumber"
  end
end

task :default => :spec

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  if File.exist?('VERSION.yml')
    config = YAML.load(File.read('VERSION.yml'))
    version = "#{config[:major]}.#{config[:minor]}.#{config[:patch]}"
  else
    version = ""
  end

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "Spork #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

