require File.dirname(__FILE__) + '/../spec_helper'
require 'benchmark'
require 'pp'

module Spork
  describe EventDispatcher do
    before(:each) do
      EventDispatcher.clear
    end

    after(:each) do
      EventDispatcher.stop
    end

    describe "::[]" do
      it "instantiates and returns an existing or new event dispatcher" do
        EventDispatcher[:work].should be_kind_of(EventDispatcher)
      end

      it "returns the same dispatcher the second time" do
        EventDispatcher[:work].object_id.should == EventDispatcher[:work].object_id
      end
    end

    describe "#observe" do
      it "observes a lambda to the queue for a given event" do
        @result = []
        receiver = lambda { |payload| @result << payload}
        EventDispatcher[:work].observe(:push_the_cart, &receiver)
        EventDispatcher[:work].trigger(:push_the_cart, {:team => "red"})
        EventDispatcher[:work].trigger(:push_the_cart, {:team => "blue"})
        EventDispatcher[:work].stop
        @result.should == [{:team => "red"}, {:team => "blue"}]
      end

      it "processes messages as soon as they come in" do
        sleep 0.05
        EventDispatcher[:work].observe(:push_the_cart) { |payload| }
        time = Benchmark.measure {
          EventDispatcher[:work].trigger(:push_the_cart, nil)
          sleep 0.05
          EventDispatcher[:work].trigger(:push_the_cart, nil)
          sleep 0.05
          EventDispatcher[:work].stop
        }.real.should be_close(0.1, 0.05)
      end
    end

    describe "#trigger" do
      it "raises an error if no observer exists to receive the event" do
        running {
          EventDispatcher[:work].trigger(:thing, 'payload')
        }.should raise_error(ArgumentError, /no observers/)
      end

      it "triggers an event on to the queue asynchronously" do
        EventDispatcher[:work].observe(:thing) { |payload| sleep(0.5) }
        Benchmark.measure {
          EventDispatcher[:work].trigger(:thing, 'payload')
        }.real.should < 0.1
      end

      it "triggers an event on to the queue synchronously" do
        EventDispatcher[:work].observe(:thing) { |payload| sleep(0.5); "result" }
        Benchmark.measure {
          EventDispatcher[:work].trigger(:thing, 'payload', :synchronous => true)
        }.real.should be_close(0.5, 0.05)
      end

      it "returns the result when a message is ran synchronously" do
        EventDispatcher[:work].observe(:thing) { |payload| "result" }
        EventDispatcher[:work].trigger(:thing, 'payload', :synchronous => true).should == "result"
      end

      it "dispatches events asynchronously across different dispatchers" do
        @start_time = Time.now
        @work_times = []
        @interrupt_times = []
        EventDispatcher[:work].observe(:time) do |payload|
          sleep 0.25
          @work_times << (Time.now - @start_time)
        end
        EventDispatcher[:interrupt].observe(:time) do |payload|
          @interrupt_times << Time.now - @start_time
        end
        EventDispatcher[:work].trigger(:time, nil)
        EventDispatcher[:work].trigger(:time, nil)
        EventDispatcher[:interrupt].trigger(:time, nil)
        EventDispatcher[:interrupt].trigger(:time, nil)
        EventDispatcher[:work].stop
        @interrupt_times.last.should <= @work_times.first

        @work_times[0].should be_close(0.25, 0.1)
        @work_times[1].should be_close(0.50, 0.1)
      end
    end

    describe "#consumer_thread" do
      it "returns the thread of the EventDispatcher loop when it's running" do
        EventDispatcher[:work].consumer_thread.should be_instance_of(Thread)
      end
    end
  end
end

