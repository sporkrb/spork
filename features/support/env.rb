require 'rubygems'
require 'fileutils'
require 'forwardable'
require 'tempfile'
require 'spec/expectations'

class SporkWorld
  RUBY_BINARY   = File.join(Config::CONFIG['bindir'], Config::CONFIG['ruby_install_name'])
  BINARY        = File.expand_path(File.dirname(__FILE__) + '/../../bin/spork')
  SANDBOX_DIR   = File.expand_path(File.join(File.dirname(__FILE__), '../../tmp/sandbox'))
  
  extend Forwardable
  def_delegators SporkWorld, :sandbox_dir, :spork_lib_dir

  def spork_lib_dir
    @spork_lib_dir ||= File.expand_path(File.join(File.dirname(__FILE__), '../../lib'))
  end

  def initialize
    @current_dir = SANDBOX_DIR
  end

  private
  attr_reader :last_exit_status, :last_stderr, :last_stdout

  def create_file(file_name, file_content)
    file_content.gsub!("CUCUMBER_LIB", "'#{spork_lib_dir}'") # Some files, such as Rakefiles need to use the lib dir
    in_current_dir do
      FileUtils.mkdir_p(File.dirname(file_name))
      File.open(file_name, 'w') { |f| f << file_content }
    end
  end

  def in_current_dir(&block)
    Dir.chdir(@current_dir, &block)
  end

  def run(command)
    stderr_file = Tempfile.new('cucumber')
    stderr_file.close
    in_current_dir do
      @last_stdout = `#{command} 2> #{stderr_file.path}`
      @last_exit_status = $?.exitstatus
    end
    @last_stderr = IO.read(stderr_file.path)
  end

  def run_in_background(command)
    background_jobs << Kernel.fork { exec command }
  end

  def terminate_background_jobs
    if @background_jobs
      @background_jobs.each do |pid|
        Process.kill(Signal.list['TERM'], pid)
      end
    end
  end

end

World do
  SporkWorld.new
end

Before do
  FileUtils.rm_rf SporkWorld::SANDBOX_DIR
  FileUtils.mkdir_p SporkWorld::SANDBOX_DIR
end

After do
  # FileUtils.rm_rf SporkWorld::SANDBOX_DIR
  terminate_background_jobs
end
