require 'rubygems'
require 'fileutils'
require 'forwardable'
require 'tempfile'
require 'spec/expectations'
require 'timeout'

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
    @background_jobs = []
  end

  private
  attr_reader :last_exit_status, :last_stderr, :last_stdout, :background_jobs

  def create_file(file_name, file_content)
    file_content.gsub!("SPORK_LIB", "'#{spork_lib_dir}'") # Some files, such as Rakefiles need to use the lib dir
    in_current_dir do
      FileUtils.mkdir_p(File.dirname(file_name))
      File.open(file_name, 'w') { |f| f << file_content }
    end
  end

  def in_current_dir(&block)
    Dir.chdir(@current_dir, &block)
  end

  def run(command)
    stderr_file = Tempfile.new('spork')
    stderr_file.close
    in_current_dir do
      @last_stdout = `#{command} 2> #{stderr_file.path}`
      @last_exit_status = $?.exitstatus
    end
    @last_stderr = IO.read(stderr_file.path)
  end

  def run_in_background(command)
    child_stdin, parent_stdin = IO::pipe
    parent_stdout, child_stdout = IO::pipe
    parent_stderr, child_stderr = IO::pipe
    
    background_jobs << Kernel.fork do
      # grandchild
      [parent_stdin, parent_stdout, parent_stderr].each { |io| io.close }
      
      STDIN.reopen(child_stdin)
      STDOUT.reopen(child_stdout)
      STDERR.reopen(child_stderr)
      
      [child_stdin, child_stdout, child_stderr].each { |io| io.close }

      in_current_dir do
        exec command
      end
    end
    
    [child_stdin, child_stdout, child_stderr].each { |io| io.close }
    parent_stdin.sync = true
    
    @bg_stdin, @bg_stdout, @bg_stderr = [parent_stdin, parent_stdout, parent_stderr]
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
