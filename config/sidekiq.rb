$: << File.join(File.dirname(__FILE__),  '../app')
require 'bundler'
Bundler.require(:default, :sidekiq)
require 'fetcher'
require 'info_fetcher'

Sidekiq.configure_server do |config|
  config.redis = { namespace: 'isbn'}
end

Sidekiq.options.merge!({environment: 'production', enable_rails_extensions: false, queues: ['fetch', 'info']})
