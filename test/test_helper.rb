require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
Dir[Rails.root.join('test/support/**/*.rb')].each { |f| require f }
Dir[Rails.root.join('test/helpers/**/*.rb')].each { |f| require f }

# DatabaseCleaner.strategy = :transaction

class ActiveSupport::TestCase
  include FactoryBot::Syntax::Methods
  include AbstractController::Translation
  include Devise::Test::IntegrationHelpers

  # http://neo4jrb.readthedocs.io/en/8.0.x/Miscellany.html#cleaning-your-database-for-testing
  teardown do
    Neo4j::ActiveBase.current_session.query %(
      MATCH (n)
      WHERE NOT (n:`Neo4j::Migrations::SchemaMigration`)
      DETACH
      DELETE n
    )
  end
end
