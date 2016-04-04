source 'https://rubygems.org'
gemspec
gem 'cucumber', '~>2.3.3'
gem 'rspec', '~>2.99.0'
gem 'rake'

if RUBY_VERSION =~ /^2\.2|^2\.1/
  gem 'byebug'
elsif RUBY_VERSION =~ /^2\.0|^1\.9/
  gem 'debugger'
else
  gem 'ruby-debug'
end
