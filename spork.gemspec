# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{spork}
  s.version = "0.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Tim Harper"]
  s.date = %q{2009-05-20}
  s.description = %q{A forking Drb spec server}
  s.email = ["timcharper+spork@gmail.com"]
  s.executables = ["spork"]
  s.extra_rdoc_files = ["README.rdoc"]
  s.files = ["README.rdoc", "lib/spork", "lib/spork/spec_server.rb", "lib/spork.rb", "assets/bootstrap.rb"] 
  s.has_rdoc = true
  s.homepage = %q{http://github.com/timcharper/spork}
  s.rdoc_options = ["--main", "README.rdoc"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{spork}
  s.rubygems_version = %q{1.3.1}
  s.summary = %{spork #{s.version}}
end
