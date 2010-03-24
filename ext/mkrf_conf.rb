require 'rubygems'
require 'rubygems/command.rb'
require 'rubygems/dependency_installer.rb' 
STDERR.puts "Actually, there aren't any native extensions. I'm just dynamically installing dependencies based off of your operating system"
begin
  Gem::Command.build_args = ARGV
  rescue NoMethodError
end 
inst = Gem::DependencyInstaller.new
begin
  inst.install "rake"
  inst.install "win32-process", "~> 0.6.1" if RUBY_PLATFORM =~ /mswin|mingw/ and RUBY_VERSION < '1.9.1'
rescue
  exit(1)
end 

f = File.open(File.join(File.dirname(__FILE__), "Rakefile"), "w")   # create dummy rakefile to indicate success
f.write("task :default\n")
f.close
