class Spork::Forker
  class ForkDiedException < Exception; end
  def initialize(&block)
    return unless block_given?
    @child_io, @server_io = UNIXSocket.socketpair
    @child_pid = Kernel.fork do
      @server_io.close
      Marshal.dump(yield, @child_io)
      # wait for the parent to acknowledge receipt of the result.
      master_response = 
        begin
          Marshal.load(@child_io)
        rescue EOFError
          nil
        end
      
      # terminate, skipping any at_exit blocks.
      exit!(0)
    end
    @child_io.close
  end
  
  def result
    return unless running?
    result_thread = Thread.new do
      begin
        @result = Marshal.load(@server_io)
        Marshal.dump('ACK', @server_io)
      rescue ForkDiedException
        @result = nil
      end
    end
    Process.wait(@child_pid)
    result_thread.raise(ForkDiedException) if @result.nil?
    @child_pid = nil
    @result
  end
  
  def abort
    if running?
      Process.kill(Signal.list['TERM'], @child_pid)
      @child_pid = nil
      true
    end
  end
  
  def running?
    return false unless @child_pid
    Process.getpgid(@child_pid)
    true
  rescue Errno::ESRCH
    false
  end
end
