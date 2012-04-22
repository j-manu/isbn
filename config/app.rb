config['redis'] = EM::Synchrony::ConnectionPool.new(:size => 20) do
  Redis.new
end
