require_relative 'boot'

require 'rails'
# Pick the frameworks you want:
require 'active_model/railtie'
require 'active_job/railtie'
# require "active_record/railtie"
require 'neo4j/railtie'
require 'action_controller/railtie'
require 'action_mailer/railtie'
require 'action_view/railtie'
require 'action_cable/engine'
require 'sprockets/railtie'
require 'rails/test_unit/railtie'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module PremestiSe
  class Application < Rails::Application
    config.generators do |g|
      g.orm :neo4j
    end

    # Configure where to connect to the Neo4j DB
    # Note that embedded db is only available for JRuby
    # config.neo4j.session.type = :http
    # config.neo4j.session.url = 'http://localhost:7474'
    #  or
    config.neo4j.session.type = Rails.application.secrets.neo4j_type == 'bolt' ? :bolt : :http
    config.neo4j.session.url =
      "#{Rails.application.secrets.neo4j_type}://" +
      Rails.application.secrets.neo4j_username.to_s + ':' +
      Rails.application.secrets.neo4j_password.to_s + '@' +
      Rails.application.secrets.neo4j_host.to_s + ':' +
      (Rails.application.secrets.neo4j_type == 'bolt' ? Rails.application.secrets.neo4j_bolt_port : Rails.application.secrets.neo4j_port).to_s
    raise "Please set env variables for NEO4J server #{config.neo4j.session.url} #{ENV['NEO4J_PORT']} ENV=#{ENV.to_hash}" unless Rails.application.secrets.values_at(
      :neo4j_type, :neo4j_username, :neo4j_password, :neo4j_host, :neo4j_port
    ).all?
    # puts 'config.neo4j.session.url=' + config.neo4j.session.url
    #  or
    # config.neo4j.session.type = :embedded
    # config.neo4j.session.path = Rails.root.join('neo4j-db').to_s

    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.1

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
    config.action_mailer.delivery_method = :smtp
    config.action_mailer.smtp_settings = {
      address: 'smtp.gmail.com',
      port: 587,
      domain: 'gmail.com',
      authentication: 'plain',
      enable_starttls_auto: true,
      user_name: Rails.application.secrets.smtp_username,
      password: Rails.application.secrets.smtp_password
    }

    link = Rails.application.secrets.default_url.symbolize_keys
    # for link urls in emails
    config.action_mailer.default_url_options = link
    # for link urls in rails console
    config.after_initialize do
      Rails.application.routes.default_url_options = link
    end
    # for asset-url or img_tag in emails
    config.action_mailer.asset_host = "http://#{link[:host]}:#{link[:port]}"

    config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml}')]

    config.active_job.queue_adapter = :sidekiq
    # note that you need to use premesti_se_mailers instead of mailers
    config.active_job.queue_name_prefix = 'premesti_se'
  end
end
