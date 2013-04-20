Sidekiq.configure_server do |config|
  config.server_middleware do |chain|
    chain.add Kiqstand::Middleware
    chain.add Kiqstool::Server
  end
end

Sidekiq.configure_client do |config|
  config.client_middleware do |chain|
    chain.add Kiqstool::Client
  end
  config.redis = { :size => 1 }
end