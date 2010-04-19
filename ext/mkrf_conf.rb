require 'rubygems'
require 'rubygems/command.rb'
require 'rubygems/dependency_installer.rb' 
STDERR.puts "Actually, there aren't any native extensions. I'm just dynamically installing dependencies based off of your operating system"
inst = Gem::DependencyInstaller.new

# this will fail if rake isn't installed.
begin
  inst.install "rake"
rescue
  # oh well.  Let it fail later.
end 

if RUBY_PLATFORM =~ /mswin|mingw/ and RUBY_VERSION < '1.9.1'
  STDERR.puts "installing windows dependencies"
  begin
    inst.install "win32-process", "~> 0.6.1"
  rescue => e
    STDERR.puts "Failed to install necessary dependency gem win32-process: #{e}"
    exit(1)
  end
end

f = File.open(File.join(File.dirname(__FILE__), "Rakefile"), "w")   # create dummy rakefile to indicate success
f.write("task :default\n")
f.close
