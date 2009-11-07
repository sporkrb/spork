module Spork
  class EventDispatcher
    class Job
      attr_accessor :waiting_thread
      def initialize
        @waiting_thread = Thread.current
      end

      def finished(result)
        raise ArgumentError, "finish must not be called from the same thread that triggered the job" if Thread.current == @waiting_thread
        @result = result
        Thread.pass until @waiting_thread.stop?
        @waiting_thread.run
      end

      def result
        raise ArgumentError, "result must be called from the thread that triggered the job" unless Thread.current == @waiting_thread
        Thread.stop
        @result
      end
    end

    attr_reader :consumer_thread

    def self.[](key)
      dispatchers[key] ||= new(key)
    end

    def initialize(name)
      @name = name
      start
    end

    def observe(event_name, &listener)
      listeners[event_name] = listener
    end

    def trigger(event_name, payload = nil, options = {})
      raise ArgumentError, "no observers for #{event_name}" unless listeners.has_key?(event_name)
      job = Job.new if options[:synchronous]
      events << [event_name, payload, job]
      @consumer_thread.wakeup
      job ? job.result : true
    end

    def start
      @consumer_thread ||= Thread.new {
        @quit = false
        while not @quit do
          Thread.stop
          begin
            process_events
          rescue Exception => e
            puts "Unhandled expection: #{e.class} #{e.message}"
            puts e.backtrace
            retry
          end
        end
      }
    end

    def stop(wait_until_empty = true)
      return unless @consumer_thread
      @quit = true
      if wait_until_empty
        @consumer_thread.wakeup
        @consumer_thread.join
      else
        @consumer_thread.kill
      end
      @consumer_thread = nil
    end

    def self.clear
      stop
      dispatchers.clear
    end

    def self.stop
      dispatchers.values.each { |d| d.stop }
    end

    private
      def self.dispatchers
        @dispatchers ||= {}
      end

      def listeners
        @listeners ||= {}
      end

      def process_events
        while (message = events.shift)
          event_name, payload, job = message
          result = listeners[event_name].call(payload)
          job.finished(result) if job
        end
        true
      end

      def events
        @events ||= []
      end
  end
end
