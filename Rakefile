require 'rubygems'
require 'bundler'
Bundler.setup

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec)

begin
  require 'cucumber/rake/task'
  Cucumber::Rake::Task.new(:features)
rescue LoadError
  task :features do
    abort "Cucumber is not available. In order to run features, you must: sudo gem install cucumber"
  end
end

task :default => :spec

require 'rdoc/task'
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


desc "Install gem bundles used for tests"
task :install_bundles do
  load File.expand_path("features/support/bundler_helpers.rb", File.dirname(__FILE__))
  Dir["features/gemfiles/*"].each do |gemfile_dir|
    BundlerHelpers.install_bundle(gemfile_dir)
    puts "done."
  end
end

namespace :gem do
  desc "Build gems"
  task :build do
    sh "rm -f spork-*.gem"
    ENV['RUBYOPT']="" # Bundler sets some options that causes gem build to fail.
    sh "gem build spork.gemspec"
    sh "env PLATFORM=x86-mingw32 gem build spork.gemspec"
    sh "env PLATFORM=x86-mswin32 gem build spork.gemspec"
  end

  desc "Build and deploy gems to rubygems.org"
  task :deploy => :build do
    Dir["spork-*.gem"].each do |g|
      sh "gem push #{g}"
    end
  end

  task :default => :build
end

# PENDING: Get this to work with gem bundler
# desc "Test all supported versions of rails"
# task :test_rails do
#   FAIL_MSG = "!! FAIL !!"
#   OK_MSG = "OK"
#   UNSUPPORTED_MSG = "Unsupported"
#   rails_gems = `gem list rails`.grep(/^rails\b/).first
#   versions = rails_gems.scan(/\((.+)\)/).flatten.first.split(", ")
#   versions_2_x_gems = versions.grep(/^2/)
#   results = {}
#   versions_2_x_gems.each do |version|
#     if version < '2.0.5'
#       puts "-----------------------------------------------------"
#       puts "Rails #{version} is not officially supported by Spork"
#       puts "Why?  http://www.nabble.com/rspec-rails-fails-to-find-a-controller-name-td23223425.html"
#       puts "-----------------------------------------------------"
#       results[version] = UNSUPPORTED_MSG
#       next
#     end
#
#
#     puts "Testing version #{version}"
#     pid = Kernel.fork do
#       test_files = %w[features/rspec_rails_integration.feature features/rails_delayed_loading_workarounds.feature]
#
#       unless version < '2.1'
#         # pending a fix, the following error happens with rails 2.0:
#         # /opt/local/lib/ruby/gems/1.8/gems/cucumber-0.3.11/lib/cucumber/rails/world.rb:41:in `use_transactional_fixtures': undefined method `configuration' for Rails:Module (NoMethodError)
#         test_files << "features/cucumber_rails_integration.feature "
#       end
#       exec("env RAILS_VERSION=#{version} cucumber #{test_files * ' '}; echo $? > result")
#     end
#     Process.waitpid(pid)
#     result = File.read('result').chomp
#     FileUtils.rm('result')
#     if result=='0'
#       results[version] = OK_MSG
#     else
#       results[version] = FAIL_MSG
#     end
#   end
#
#   puts "Results:"
#   File.open("TESTED_RAILS_VERSIONS.txt", 'wb') do |f|
#     results.keys.sort.each do |version|
#       s = "#{version}:\t#{results[version]}"
#       f.puts(s)
#       puts(s)
#     end
#   end
#   if results.values.any? { |r| r == FAIL_MSG }
#     exit 1
#   else
#     exit 0
#   end
# end
