class Move
  include Neo4j::ActiveNode
  # a_name is just for debugging
  property :a_name, type: String
  # property :available_from_date, type: Date
  # property :available_to_date, type: Date
  property :created_at, type: DateTime
  property :updated_at, type: DateTime

  has_one :in, :from_group, type: :CURRENT, model_class: :Group, unique: true
  has_many :out, :to_groups, type: :PREFER, model_class: :Group, unique: true
  # property :priority, is on relationship, and not so important for now
  has_one :in, :user, origin: :moves
  has_many :in, :chats, origin: :moves

  validates :from_group, :user, presence: true
  validate :_same_age

  def group_age_and_locations
    from_group.location.name + ' ' +
      from_group.age_with_short_title + '(↪ ' +
      to_groups.map { |group| group.location.name }.join(',') + ')'
  end

  def show_locations
    from_group.location.name + ' ' \
      '(↪ ' + to_groups.map { |group| group.location.name }.join(',') + ')'
  end

  def destroy_and_update_chats
    chats.each do |chat|
      Message.create chat: chat, text: I18n.t('one_user_deleted_move')
      chat.moves.delete(self)
    end
    destroy
  end

  def _same_age
    return unless from_group
    to_groups.each do |group|
      errors.add :to_groups, I18n.t('groups_have_to_be_same_age') if group.age != from_group.age
    end
  end
end
