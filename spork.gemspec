require 'date'
Gem::Specification.new do |s|
  s.name = %q{spork}
  s.version = "0.9.0.rc8"

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
  s.homepage = %q{http://github.com/timcharper/spork}
  s.rdoc_options = ["--main", "README.rdoc"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{spork}
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{spork}
  s.test_files = Dir["features/**/*"] + Dir["spec/**/*"]

  if ENV['PLATFORM']
    s.platform = ENV['PLATFORM']

    # This is probably bad since we're assuming when ENV['PLATFORM'] is set,
    # it's windows.
    s.add_dependency('win32-process')
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

