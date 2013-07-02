source 'https://rubygems.org'
gemspec
gem 'cucumber', '~> 1.0.0'
gem 'rspec', '~> 2.8'
gem 'rake'
gem "spork", :path => File.expand_path("../", __FILE__)

group :debug do
  if RUBY_VERSION =~ /^2\.0|^1\.9/
    gem 'debugger'
  else
    gem 'ruby-debug'
  end
end
