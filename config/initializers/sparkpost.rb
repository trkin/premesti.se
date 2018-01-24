# https://github.com/the-refinery/sparkpost_rails#additional-configuration
SparkPostRails.configure do |c|
  c.api_key = Rails.application.secrets.sparkpost_api_key
end
