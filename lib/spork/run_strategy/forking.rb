class Spork::RunStrategy::Forking < Spork::RunStrategy
  def self.available?
    Kernel.respond_to?(:fork)
  end

  def run(argv, stderr, stdout)
    Spork.increase_run_count

    child = ::Spork::Forker.new do
      $stdout, $stderr = stdout, stderr
      load test_framework.helper_file
      Spork.exec_each_run
      result = test_framework.run_tests(argv, stderr, stdout)
      Spork.exec_after_each_run
      result
    end
    child.result
  end

  def preload
    test_framework.preload
  end

  def assert_ready!
    raise RuntimeError, "This process hasn't loaded the environment yet by loading the prefork block" unless Spork.using_spork?
  end
end
