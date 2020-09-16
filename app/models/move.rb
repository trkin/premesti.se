class Move
  include Neo4j::ActiveNode
  ADMIN_INACTIVE_ARCHIVED_REASON = :inactive_user
  SUCCESS_ARHIVED_REASON = :successfully_replaced
  FAILED_ARCHIVED_REASONS = %i[
    added_move_by_mistake
    it_moved_in_the_meantime
    do_not_need_to_move_anymore
  ].freeze

  # a_name is just for debugging
  property :a_name, type: String
  # property :available_from_date, type: Date
  # property :available_to_date, type: Date
  property :created_at, type: DateTime
  property :updated_at, type: DateTime

  has_one :in, :from_group, type: :CURRENT, model_class: :Group, unique: true
  has_many :out, :to_groups, type: :PREFER, model_class: :Group, unique: true
  has_one :in, :user, origin: :moves
  has_many :in, :chats, origin: :moves
  has_many :in, :sharing_users, origin: :shared_moves, model_class: :User

  validates :from_group, :user, presence: true
  validate :_same_age
  validate :_only_one_from_same_location_and_group, on: :create

  def group_age_and_locations
    from_group.location.name + ' ' +
      from_group.age_with_short_title + ' (' +
      to_groups.map { |group| group.location.name }.join(', ') + ')'
  end

  def group_age_and_locations_en
    from_group.location.name_en + ' ' +
      from_group.age_with_short_title + ' (' +
      to_groups.map { |group| group.location.name_en }.join(', ') + ')'
  end

  def group_age_and_particular_group_location(group)
    from_group.location.name + ' ' +
      from_group.age_with_short_title + ' (' +
      group.location.name + ')'
  end

  def name_address_group_full_age_and_locations
    from_group.location.name + ' ' + from_group.location.address + ' ' +
      from_group.age_with_title +
      to_groups.map { |group| "\n↪ " + group.location.name + '(' + group.location.address + ')' }.join
  end

  def show_locations
    from_group.location.name + ' ' \
      '( ' + to_groups.map { |group| group.location.name }.join(', ') + ')'
  end

  def same_moves_for_to_group(to_group)
    Move.query_as(:move)
      .match('(from_g:Group)-[CURRENT]-(move)-[PREFER]-(to_g:Group)')
      .where('from_g.uuid = ?', from_group.id)
      .where('to_g.uuid = ?', to_group.id)
      .where('move.uuid <> ?', id)
      .pluck(:move)
  end

  def destroy_to_group_and_archive_chats(target_group, archived_reason, admin: false)
    # chats have chat1, chat2 and each
    # chat have move1, move2... each belongs to location1, location2 and
    # if target_group belongs to same location that it means that move was
    # used for matching, so we remove that chat
    target_chats = chats.query_as(:c).match(%(
      (c)-[:MATCHES]->(m:Move),
      (m)-[:CURRENT]-(g:Group),
      (g)-[:HAS_GROUPS]-(l:Location)
    )).where(%(
      l.uuid = '#{target_group.location.id}'
    )).pluck(:c)
    target_chats.each do |chat|
      chat.archive_for_move_and_reason self, archived_reason, admin: admin
    end
    to_groups.delete target_group
    touch # we need this because of cache on landing page
  end

  def destroy_and_archive_chats(archived_reason, admin: false)
    chats.active.each do |chat|
      chat.archive_for_move_and_reason self, archived_reason, admin: admin
    end
    destroy
  end

  # if you add directly group to location: move.to_groups << group
  # then you can call move.save! to check this validation
  def _same_age
    return unless from_group

    to_groups.each do |group|
      errors.add :to_groups, I18n.t('groups_have_to_be_same_age') if group.age != from_group.age
    end
  end

  def _only_one_from_same_location_and_group
    return if user.moves.from_group.where(uuid: from_group.uuid).empty?

    errors.add :base, I18n.t('only_one_from_same_location_and_group')
  end
end
