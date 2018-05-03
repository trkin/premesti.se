class Move
  include Neo4j::ActiveNode
  property :birth_date, type: Date
  property :name, type: String
  property :available_from_date, type: Date
  property :available_to_date, type: Date
  property :created_at, type: DateTime
  property :updated_at, type: DateTime

  has_one :in, :from_group, type: :CURRENT, model_class: :Group, unique: true
  has_many :out, :to_groups, type: :PREFER, model_class: :Group, unique: true
  # property :priority, is on relationship, and not so important for now
  has_one :in, :user, origin: :moves
  has_many :in, :chats, origin: :moves

  validates :from_group, :user, presence: true

  def add_to_group(group)
    if to_groups.include? group
      errors.add(:to_groups, ApplicationController.helpers.t('neo4j.errors.messages.already_exists'))
      false
    else
      to_groups << group
      true
    end
  end

  def group_age_and_locations
    from_group.location.name + " " +
      from_group.age_with_short_title + "(" +
      to_groups.map { |group| group.location.name }.join(',') + ")"
  end
end
