require 'rubygems'
require 'spec'

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
SPEC_TMP_DIR = File.dirname(__FILE__) + "/tmp"
require 'spork'
require 'spork/runner.rb'
require 'spork/server.rb'
require 'spork/diagnoser.rb'
require 'stringio'
require 'fileutils'

Spec::Runner.configure do |config|
  config.before(:each) do
    $test_stdout = StringIO.new
    $test_stderr = StringIO.new
  end
  
  config.after(:each) do
    FileUtils.rm_rf(SPEC_TMP_DIR)
  end
end


module Spec
  module Matchers
    class IncludeAStringLike
      def initialize(substring_or_regex)
        case substring_or_regex
        when String
          @regex = Regexp.new(Regexp.escape(substring_or_regex))
        when Regexp
          @regex = substring_or_regex
        else
          raise ArgumentError, "don't know what to do with the #{substring_or_regex.class} you provided"
        end
      end

      def matches?(list_of_strings)
        @list_of_strings = list_of_strings
        @list_of_strings.any? { |s| s =~ @regex }
      end
      def failure_message
        "#{@list_of_strings.inspect} expected to include a string like #{@regex.inspect}"
      end
      def negative_failure_message
        "#{@list_of_strings.inspect} expected to not include a string like #{@regex.inspect}, but did"
      end
    end

    def include_a_string_like(substring_or_regex)
      IncludeAStringLike.new(substring_or_regex)
    end
  end
end

module Spork::TestIOStreams
  def self.included(klass)
    klass.send(:extend, ::Spork::TestIOStreams::ClassMethods)
  end
  
  def stderr
    self.class.stderr
  end

  def stdout
    self.class.stdout
  end
  
  module ClassMethods
    def stderr
      $test_stderr
    end
  
    def stdout
      $test_stdout
    end
  end
end