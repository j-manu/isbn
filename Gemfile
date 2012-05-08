source 'https://rubygems.org'

gem 'rake'
gem 'hiredis', '~> 0.4.5'
gem 'yajl-ruby', require: ['yajl', 'yajl/json_gem']
gem 'activesupport', '~> 3.2', require: ['active_support/core_ext/object/blank',
                                          'active_support/core_ext/string/inflections']

group :sidekiq do
  gem 'redis', '~> 2.2.2'
  gem 'sidekiq'
  gem 'mechanize'
end

group :app do
  gem 'goliath'
  gem 'slim'
  gem 'redis', '~> 2.2.2', require: ['redis/connection/synchrony', 'redis']
end

group :deployment do
  gem 'foreman'
end
