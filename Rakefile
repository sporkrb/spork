require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |s|
    s.name = %q{spork}
    s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
    s.authors = ["Tim Harper"]
    s.date = Date.today.to_s
    s.description = %q{A forking Drb spec server}
    s.email = ["timcharper+spork@gmail.com"]
    s.executables = ["spork"]
    s.extra_rdoc_files = ["README.rdoc", "MIT-LICENSE"]
    s.files = ["README.rdoc", "MIT-LICENSE"] + Dir["lib/**/*"] + Dir["assets/**/*"] + Dir["spec/**/*"] + Dir["features/**/*"]
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
    require 'yaml'
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


# These are new tasks
begin
  require 'rake/contrib/sshpublisher'
  namespace :rubyforge do

    desc "Release gem and RDoc documentation to RubyForge"
    task :release => ["rubyforge:release:gem", "rubyforge:release:docs"]

    namespace :release do
      desc "Publish RDoc to RubyForge."
      task :docs => [:rdoc] do
        config = YAML.load(
            File.read(File.expand_path('~/.rubyforge/user-config.yml'))
        )

        host = "#{config['username']}@rubyforge.org"
        remote_dir = "/var/www/gforge-projects/spork/"
        local_dir = 'rdoc'

        Rake::SshDirPublisher.new(host, remote_dir, local_dir).upload
      end
    end
  end
rescue LoadError
  puts "Rake SshDirPublisher is unavailable or your rubyforge environment is not configured."
end

task :test_rails do
  FAIL_MSG = "!! FAIL !!"
  OK_MSG = "OK"
  UNSUPPORTED_MSG = "Unsupported"
  rails_gems = `gem list rails`.grep(/^rails\b/).first
  versions = rails_gems.scan(/\((.+)\)/).flatten.first.split(", ")
  versions_2_x_gems = versions.grep(/^2/)
  results = {}
  versions_2_x_gems.each do |version|
    if version < '2.0.5'
      puts "-----------------------------------------------------"
      puts "Rails #{version} is not officially supported by Spork"
      puts "Why?  http://www.nabble.com/rspec-rails-fails-to-find-a-controller-name-td23223425.html"
      puts "-----------------------------------------------------"
      results[version] = "unsupported"
      next
    end
    
    
    puts "Testing version #{version}"
    pid = Kernel.fork do
      test_files = %w[features/rspec_rails_integration.feature features/rails_delayed_loading_workarounds.feature]
      
      unless version < '2.1'
        # pending a fix, the following error happens with rails 2.0:
        # /opt/local/lib/ruby/gems/1.8/gems/cucumber-0.3.11/lib/cucumber/rails/world.rb:41:in `use_transactional_fixtures': undefined method `configuration' for Rails:Module (NoMethodError)
        test_files << "features/cucumber_rails_integration.feature "
      end
      exec("env RAILS_VERSION=#{version} cucumber #{test_files * ' '}; echo $? > result")
    end
    Process.waitpid(pid)
    result = File.read('result').chomp
    FileUtils.rm('result')
    if result=='0'
      results[version] = OK_MSG
    else
      results[version] = FAIL_MSG
    end
  end
  
  puts "Results:"
  results.keys.sort.each do |version|
    puts "#{version}:\t#{results[version]}"
  end
  if results.values.any? { |r| r == FAIL_MSG }
    exit 1
  else
    exit 0
  end
end
