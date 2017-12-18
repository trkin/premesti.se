class LandingSignup
  include ActiveModel::Model
  REQUIRED_FIELDS = %i[current_city current_location from_group email password].freeze
  OPTIONAL_FIELDS = %i[prefered_group].freeze
  FIELDS = REQUIRED_FIELDS + OPTIONAL_FIELDS
  attr_accessor(*FIELDS)
  attr_reader :user, :move, :existing_user
  # other helpers: :notice, :alert

  validates(*REQUIRED_FIELDS, presence: true)
  # rubocop:disable  Style/ColonMethodCall
  validates_format_of :email, with: Devise::email_regexp

  def perform
    return false unless valid?
    return false unless _create_or_find_user?
    _create_move!

    UserMailer.landing_signup(@move).deliver_now
    true
  end

  def _create_or_find_user?
    if User.find_by email: @email
      _valid_existing_user?
    else
      @user = User.new email: @email, password: @password
      @user.skip_confirmation_notification! # we will manually send confirmation
      @user.valid?
    end
  end

  def _valid_existing_user?
    user = User.find_by email: @email
    if user.valid_password? password
      @user = user
      @existing_user = true
      true
    else
      errors.add :password, I18n.t("errors.messages.invalid")
      errors.add :base, I18n.t("landing_signup.user_registered_but_password_is_invalid")
      false
    end
  end

  def _create_move!
    from_group = Group.find @from_group
    @move = Move.create! user: @user, from_group: from_group
    return unless @prefered_group.present?
    prefered_group = Group.find @prefered_group
    @move.prefered_groups << prefered_group
  end

  def notice
    notice = I18n.t("landing_signup.success_notice")
    notice += I18n.t("devise.registrations.signed_up_but_unconfirmed") unless user.confirmed?
    notice
  end

  # return hash {city_id: [{id: l1.id, name: l1.name}, ...], ...}
  def self.locations_by_city_id
    Location.all.each_with_object({}) do |location, result|
      if result[location.city_id].present?
        result[location.city_id].append(id: location.id, name: location.name)
      else
        result[location.city_id] = [{ id: location.id, name: location.name }]
      end
    end
  end

  # return hash {location_id: [{id: group.id, name: group.name}, ...], ...}
  def self.groups_by_location_id
    Group.all.each_with_object({}) do |group, result|
      if result[group.location_id].present?
        result[group.location_id].append(id: group.id, name: group.name)
      else
        result[group.location_id] = [{ id: group.id, name: group.name }]
      end
    end
  end

  # return hash {group_id: [id: group.id, name: group.location.name}, ...]...}
  # groups on other locations from same city
  # TODO: sometimes age is not provided, but birth_date_min birth_date_max
  def self.groups_by_group_id
    Group.all.each_with_object({}) do |group, result|
      groups = group
               .query_as(:g)
               .match(
                 '(g)<-[:HAS_GROUPS]-(l),
                 (l)-[:IN_CITY]->(c),(c)<-[:IN_CITY]-(other_loc),
                 (other_loc)-[:HAS_GROUPS]->(other_group)'
               )
               .where('g <> other_group').where('g.age = other_group.age').pluck(:other_group)
               .map { |g| { id: g.id, name: g.location.name } }
      result[group.id] = groups
    end
  end
end
