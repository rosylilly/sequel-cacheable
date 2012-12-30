source :rubygems

gem 'bundler'
gem 'rake'

gemspec

group :development, :test do
  gem 'rspec', "~> 2.12.0"
  gem 'yard', "~> 0.8.3"
  gem 'rdoc', "~> 3.12"
  gem 'simplecov', "~> 0.7.1", :require => false

  gem 'guard', '~> 1.6.1'
  gem 'guard-rspec', '~> 2.3.3'
  gem 'terminal-notifier'
  gem 'listen', '~> 0.7.0'

  gem 'sqlite3'
  gem 'dalli'
  gem 'memcache'
  gem 'hiredis'
  gem 'redis', :require => ['redis', 'redis/connection/hiredis']
  gem 'pry'
end
