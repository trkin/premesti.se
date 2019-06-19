# Heroku timeout is 30s
Rails.application.config.middleware.insert_before Rack::Runtime, Rack::Timeout, service_timeout: 30

# do not use same log file as Rails
Rack::Timeout::Logger.logger = Logger.new('log/timeout.log')
Rack::Timeout::Logger.logger.level = Logger::ERROR
