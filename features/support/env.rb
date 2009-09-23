require 'rubygems'
require 'fileutils'
require 'forwardable'
require 'tempfile'
require 'spec/expectations'
require 'timeout'
require 'spork'

require(File.dirname(__FILE__) + '/background_job.rb')

class SporkWorld
  BINARY        = File.expand_path(File.dirname(__FILE__) + '/../../bin/spork')
  RUBY_BINARY   = File.join(Config::CONFIG['bindir'], Config::CONFIG['ruby_install_name'])
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
  def last_stderr
    return @last_stderr if @last_stderr
    if @background_job
      @last_stderr = @background_job.stderr.read
    end
  end


  def last_stdout
    return @last_stdout if @last_stdout
    if @background_job
      @last_stdout = @background_job.stdout.read
    end
  end

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

  def localized_command(command, args)
    case command
    when 'spork'
      command = SporkWorld::BINARY
    when 'cucumber'
      command = Cucumber::BINARY
    else
      command = %x{which #{command}}.chomp
    end
    "#{SporkWorld::RUBY_BINARY} -I #{Cucumber::LIBDIR} #{command} #{args}"
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
    in_current_dir do
      @background_job = BackgroundJob.run(command)
    end
    @background_jobs << @background_job
    @background_job
  end

  def terminate_background_jobs
    if @background_jobs
      @background_jobs.each do |background_job|
        background_job.kill
      end
    end
    @background_jobs.clear
    @background_job = nil
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
