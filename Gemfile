source 'https://rubygems.org'

gem 'rake'
gem 'hiredis', '~> 0.4.5'
gem 'yajl-ruby', require: ['yajl', 'yajl/json_gem']

group :resque do
  gem 'redis', '~> 2.2.2'
  gem 'resque'
  gem 'mechanize'
end

group :app do
  gem 'goliath'
  gem 'slim'
  gem 'redis', '~> 2.2.2', require: ['redis/connection/synchrony', 'redis']
end

