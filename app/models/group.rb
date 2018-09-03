class Group
  include Neo4j::ActiveNode
  property :name, type: String
  # age range is fixed, every year admin will update birth date range and send
  # notification to existing users about new chances, for example two new groups
  property :age, type: Integer # 1, 2, 3, 4, 5, 6, 7
  # property :birth_date_min, type: Date
  # property :birth_date_max, type: Date
  property :updated_at, type: DateTime

  has_one :in, :location, origin: :groups
  has_many :in, :move, origin: :from_group

  validates :location, presence: true
  validates :age, numericality: { greater_than: 0 }
  validate :age_overlaps

  def age_overlaps
    return unless age.to_i.positive?
    return unless location
    return unless location.groups.for_age(age, id).present?
    errors.add :age, I18n.t('group_with_that_age_already_exists')
  end

  scope :for_age, ->(age, except_id) { where(age: age).where_not(id: except_id) }

  def self.title_for_age(age)
    # on 01.09 every year we need to increase age
    # Location.all.each {|l| l.groups.query_as(:g).order('g.age DESC').pluck(:g).map { |g| g.age += 1; g.save! } }
    # do not need to create new groups for age 1 since we use
    # Group.find_or_create_by_location_id_and_age
    # during Sept-Dec we need to show next year
    # half of the kids will fulfill that age until 1. Septembar (end of school
    # period of that group) and half will not
    year = Time.zone.today.year - age
    year += 1 if Time.zone.today.month >= 9
    age_interval = "01.03.#{year}-28.02.#{year + 1}"
    "#{I18n.t('born')} #{age_interval} #{I18n.t("group_name_for_age_#{age}")} #{short_title_for_age age}"
  end

  def self.short_title_for_age(age)
    "#{age} #{I18n.t('year')}"
  end

  def age_with_title
    self.class.title_for_age age
  end

  def age_with_short_title
    self.class.short_title_for_age age
  end

  def self.find_or_create_by_location_id_and_age(location_id, age)
    from_location = Location.find location_id
    from_group = from_location.groups.find_by age: age
    # if_not_exists_create_new
    from_group ||= Group.create! location: from_location, age: age
    from_group
  end
end
