require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
Dir[Rails.root.join('test/support/**/*.rb')].each { |f| require f }
Dir[Rails.root.join('test/helpers/**/*.rb')].each { |f| require f }

# DatabaseCleaner.strategy = :transaction

class ActiveSupport::TestCase
  # create(:user) instead FactoryBot.create :user
  include FactoryBot::Syntax::Methods
  # t('successfully') instead I18n.t('successfully')
  include AbstractController::Translation
  # t_crud('success_create', Message)
  include TranslateHelper
  # sign_in user
  include Devise::Test::IntegrationHelpers
  # clear_mails, give_me_last_mail_and_clear_mails
  include MailerHelpers
  # assert_performed_jobs
  include ActiveJob::TestHelper

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
