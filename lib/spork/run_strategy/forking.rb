class Spork::RunStrategy::Forking < Spork::RunStrategy
  def self.available?
    Kernel.respond_to?(:fork)
  end

  def running?
    @child && @child.running?
  end

  protected
    def do_run(argv, stderr, stdout)
      abort if running?

      @child = ::Spork::Forker.new do
        $stdout, $stderr = stdout, stderr
        load test_framework.helper_file
        Spork.exec_each_run
        test_framework.run_tests(argv, stderr, stdout)
      end
      @child.result
    end

    def do_abort
      @child && @child.abort
    end

    def do_preload
      test_framework.preload
    end

end