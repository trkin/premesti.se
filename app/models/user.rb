class User
  include Neo4j::ActiveNode

  property :created_at, type: DateTime
  property :updated_at, type: DateTime

  ## Database authenticatable
  property :email, type: String, default: ''
  validates :email, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i }
  property :name, type: String

  property :encrypted_password

  ## If you include devise modules, uncomment the properties below.

  ## Recoverable
  property :reset_password_token
  property :reset_password_sent_at, type: DateTime

  ## Rememberable
  property :remember_created_at, type: DateTime

  ## Trackable
  property :sign_in_count, type: Integer, default: 0
  validates :sign_in_count, presence: true
  property :current_sign_in_at, type: DateTime
  property :last_sign_in_at, type: DateTime
  property :current_sign_in_ip, type: String
  property :last_sign_in_ip, type: String

  ## Confirmable
  property :confirmation_token
  property :confirmed_at, type: DateTime
  property :confirmation_sent_at, type: DateTime
  property :unconfirmed_email # Only if using reconfirmable

  ## Lockable
  # property :failed_attempts, type: Integer, default: 0 # Only if lock strategy is :failed_attempts
  # validates :failed_attempts, presence: true
  # property :unlock_token, type: String # Only if unlock strategy is :email or :both
  # property :locked_at, type: DateTime

  ## Token authenticatable
  # property :authentication_token, type: String

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable,
         :omniauthable

  property :auth, type: String
  property :facebook_uid, type: String
  property :google_uid, type: String

  property :admin, type: Boolean

  property :locale, type: String
  validates :locale, presence: true

  property :status, type: Integer, default: 0
  enum status: %i[active email_bounce]

  property :initial_referrer, type: String
  property :last_referrer, type: String

  has_many :out, :moves, type: :WANTS

  has_many :out, :messages, type: :AUTHOR_OF
  has_many :out, :email_messages, type: :RECEIVED

  scope :confirmed, -> { query_as(:user).where('user.confirmed_at IS NOT NULL').pluck(:user) }

  def generate_new_confirmation_token!
    generate_confirmation_token!
    @raw_confirmation_token
  end

  def email_username
    email.split('@').first
  end

  def my_data
    {
      user: self,
      moves: moves.map(&:group_age_and_locations),
      chats: moves.chats.map { |c| c.name_for_user(self) + ':' + c.messages.where(user: self).map(&:text).join('|') },
    }
  end

  def destroy_moves_and_messages
    messages.each do |message|
      message.user = nil
      message.text = I18n.t('user_canceled_account')
      message.save!
    end
    moves.each do |move|
      move.destroy_and_archive_chats 'user_canceled_account'
    end
    destroy
  end

  # This method overwrites devise's own `send_devise_notification`
  # message = devise_mailer.send(notification, self, *args)
  # message.deliver_now
  # also need to fetch user in MyDeviseMailer
  # protected is required, or ActionView::Template::Error: undefined method `main_app'

  protected

  def send_devise_notification(notification, *args)
    message = devise_mailer.send(notification, id, *args)
    message.deliver_later
  end
end
