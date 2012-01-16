require 'date'
Gem::Specification.new do |s|
  s.name = %q{spork}
  s.version = "0.9.0.rc9"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Tim Harper", "Donald Parish"]
  s.date = Date.today.to_s
  s.description = %q{A forking Drb spec server}
  s.email = ["timcharper+spork@gmail.com"]
  s.executables = ["spork"]
  s.extra_rdoc_files = [
    "MIT-LICENSE",
     "README.rdoc"
  ]
  s.files = ["Gemfile", "README.rdoc", "MIT-LICENSE"] + Dir["lib/**/*"] + Dir["assets/**/*"]
  s.homepage = %q{https://github.com/sporkrb/spork}
  s.rdoc_options = ["--main", "README.rdoc"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{spork}
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{spork}
  s.test_files = Dir["features/**/*"] + Dir["spec/**/*"]

  case ENV['PLATFORM']
  when NilClass
  when "x86-mingw32", "x86-mswin32"
    s.platform = ENV['PLATFORM']
    s.add_dependency('win32-process')
  else
    STDERR.puts "Warning: no customization for #{ENV['PLATFORM']}"
  end

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end

