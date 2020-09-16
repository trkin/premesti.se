class UserFromOmniauth
  class Result
    attr_reader :message, :user
    def initialize(message, attr = {})
      @message = message
      @user = attr[:user]
    end

    def success?
      true
    end
  end

  class Error < Result
    def success?
      false
    end
  end

  def initialize(auth, referrer)
    @auth = auth
    @referrer = referrer
  end

  def perform
    user = _find_existing
    return Result.new('Existing', user: user) if user

    user = create_new_with_generated_password
    if user.new_record?
      Error.new user.errors.full_messages.join(', ')
    else
      Result.new 'New', user: user
    end
  end

  def _find_existing
    user = User.find_by(email: @auth.info.email)
    # user changed his email on facebook
    user ||= if @auth.provider == 'facebook'
               User.find_by(facebook_uid: @auth.uid)
             else
               User.find_by(google_uid: @auth.uid)
             end
    return nil unless user

    update_auth user
    user
  end

  def update_auth(user)
    if user.auth != @auth.to_json
      user.auth = @auth.to_json
      if @auth.provider == 'facebook'
        user.facebook_uid = @auth.uid
      else
        user.google_uid = @auth.uid
      end
      if @auth.info.email.present? && user.email != @auth.info.email
        user.email = @auth.info.email
        # I found that only this two commands can update email and confirm
        user.save validate: false
        user.confirm
      end
    end
    user.last_referrer = @referrer if user.last_referrer != @referrer
    user.save!
  end

  def create_new_with_generated_password
    params = {
      email: @auth.info.email,
      password: Devise.friendly_token[0, 20],
      # confirmed_at: Time.zone.now,
      locale: I18n.locale,
      auth: @auth.to_json,
      initial_referrer: @referrer,
    }
    if @auth.provider == 'facebook'
      params[:facebook_uid] = @auth.uid
    else
      params[:google_uid] = @auth.uid
    end
    # user.skip_confirmation! # this will just add confirmed_at = Time.now
    # user.name = @auth.info.name # assuming the user model has a name
    # user.image = @auth.info.image # assuming the user model has an image
    User.create params
  end
end
