config['redis'] = EM::Synchrony::ConnectionPool.new(:size => 20) do
  Redis.new
end

environment :production do
  config['host'] = 'http://isbn.startupgang.com'
end

environment :development do
  config['host'] = 'http://localhost:9000'
end
