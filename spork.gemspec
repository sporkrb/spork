# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{spork}
  s.version = "0.3.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Tim Harper"]
  s.date = %q{2009-05-25}
  s.default_executable = %q{spork}
  s.description = %q{A forking Drb spec server}
  s.email = ["timcharper+spork@gmail.com"]
  s.executables = ["spork"]
  s.extra_rdoc_files = [
    "README.rdoc"
  ]
  s.files = [
    "History.txt",
     "README.rdoc",
     "assets/bootstrap.rb",
     "lib/spork.rb",
     "lib/spork/runner.rb",
     "lib/spork/spec_server.rb"
  ]
  s.homepage = %q{http://github.com/timcharper/spork}
  s.rdoc_options = ["--main", "README.rdoc"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{spork}
  s.rubygems_version = %q{1.3.3}
  s.summary = %q{spork 0.3}
  s.test_files = [
    "spec/spec_helper.rb",
     "spec/spork_spec.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
