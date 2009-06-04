class Spork::Diagnoser
  class << self
    def loaded_files
      @loaded_files ||= {}
    end
    
    def install_hook!(dir = Dir.pwd)
      @dir = File.expand_path(Dir.pwd, dir)
      
      Kernel.class_eval do
        alias :require_without_diagnoser :require
        alias :load_without_diagnoser :load
        
        def require(string)
          ::Spork::Diagnoser.add_included_file(string, caller)
          require_without_diagnoser(string)
        end
        
        def load(string)
          ::Spork::Diagnoser.add_included_file(string, caller)
          load_without_diagnoser(string)
        end
      end
    end
    
    def add_included_file(filename, callstack)
      filename = expand_filename(filename)
      return unless File.exist?(filename)
      loaded_files[filename] = caller.select { |f| ! f.include?('lib/spork/diagnoser.rb')} if subdirectory?(filename)
    end
    
    def expand_filename(filename)
      ([Dir.pwd] + $:).each do |attempted_path|
        attempted_filename = File.expand_path(filename, attempted_path)
        return attempted_filename if File.file?(attempted_filename)
        attempted_filename = attempted_filename + ".rb"
        return attempted_filename if File.file?(attempted_filename)
      end
      filename
    end
    
    def subdirectory?(directory)
      File.expand_path(directory, Dir.pwd).include?(@dir)
    end
    
    def remove_hook!
      return unless Kernel.private_instance_methods.include?('require_without_diagnoser')
      Kernel.class_eval do
        alias :require :require_without_diagnoser
        alias :load :load_without_diagnoser
        
        undef_method(:require_without_diagnoser)
        undef_method(:load_without_diagnoser)
      end
      true
    end
    
    def output_results(stdout)
      project_prefix = Dir.pwd + "/"
      minimify = lambda { |f| f.gsub(project_prefix, '')}
      stdout.puts "- Spork Diagnosis -\n"
      stdout.puts "-- Summary --"
      stdout.puts loaded_files.keys.sort.map(&minimify)
      stdout.puts "\n\n\n"
      stdout.puts "-- Detail --"
      loaded_files.keys.sort.each do |file|
        stdout.puts "\n\n\n--- #{minimify.call(file)} ---\n"
        stdout.puts loaded_files[file].map(&minimify)
      end
    end
  end
end
