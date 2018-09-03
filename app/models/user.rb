class User
  include Neo4j::ActiveNode

  property :created_at, type: DateTime
  property :updated_at, type: DateTime

  ## Database authenticatable
  property :email, type: String, default: ''
  validates :email, presence: true
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

  property :facebook_uid, type: String
  property :google_uid, type: String

  property :admin, type: Boolean

  property :locale, type: String
  validates :locale, presence: true

  has_many :out, :moves, type: :WANTS

  has_many :out, :messages, type: :AUTHOR_OF

  scope :confirmed, -> { query_as(:user).where('user.confirmed_at IS NOT NULL').pluck(:user) }

  def self._find_existing(provider, email, uid)
    user = find_by(email: email)
    return user if user
    # user changed his email on facebook
    user = if provider == 'facebook'
             find_by(facebook_uid: uid)
           else
             find_by(google_uid: uid)
           end
    user
  end

  def self.create_new_with_some_password(provider, email, uid)
    params = {
      email: email,
      password: Devise.friendly_token[0, 20],
      confirmed_at: Time.zone.now,
      locale: I18n.locale,
    }
    if provider == 'facebook'
      params.merge facebook_uid: uid
    else
      params.merge google_uid: uid
    end
    User.create! params
  end

  def self.from_omniauth!(auth)
    user = _find_existing(auth.provider, auth.info.email, auth.uid)
    return user if user
    user = create_new_with_some_password(auth.provider, auth.info.email, auth.uid)
    user.skip_confirmation! # this will just add confirmed_at = Time.now
    # user.name = auth.info.name # assuming the user model has a name
    # user.image = auth.info.image # assuming the user model has an image
    user
  end

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
