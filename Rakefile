$: << File.dirname(__FILE__)
$: << File.join(File.dirname(__FILE__),  'app')
require 'bundler'
Bundler.require(:default, :resque)
require 'fetcher'
require 'resque/tasks'
require 'lib/tasks/worker'
