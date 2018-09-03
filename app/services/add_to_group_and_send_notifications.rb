class AddToGroupAndSendNotifications
  class Result
    attr_reader :message
    def initialize(message)
      @message = message
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

  def initialize(move, group)
    @move = move
    @group = group
  end

  def perform(max_length_of_the_rotation: nil)
    return Error.new(@move.errors.values.join(', ')) unless _validate_that_group_can_be_added?
    @move.to_groups << @group
    create_and_send_notifications max_length_of_the_rotation: max_length_of_the_rotation
  end

  def create_and_send_notifications(max_length_of_the_rotation: nil)
    return Error.new(@move.errors.values.join(', ')) if ignore_sending_notification?
    results = FindMatchesForOneMove.perform @move, target_group: @group, max_length_of_the_rotation: max_length_of_the_rotation
    count = 0
    results.each do |moves|
      result = CreateChatAndSendNotifications.new(@move, moves).perform
      count += result.chat.moves.size - 1 if result.success?
    end
    if count.positive?
      Result.new I18n.t('request_created_and_sent_notifications_successfully', count: count)
    else
      Result.new I18n.t('request_created')
    end
  end

  def ignore_sending_notification?
    unless @move.user.confirmed?
      @move.errors.add(:to_groups, ApplicationController.helpers.t('ignored_sending_notifications_unconfirmed_user'))
    end
    @move.errors.present?
  end

  # rubocop:disable Metrics/AbcSize
  def _validate_that_group_can_be_added?
    if !@group.present?
      @move.errors.add(:to_groups, ApplicationController.helpers.t('neo4j.errors.messages.required'))
    elsif @move.to_groups.include? @group
      @move.errors.add(:to_groups, ApplicationController.helpers.t('neo4j.errors.messages.already_exists'))
    elsif @move.from_group.age != @group.age
      @move.errors.add :to_groups, I18n.t('groups_have_to_be_same_age')
    elsif @move.from_group == @group
      @move.errors.add :to_groups, I18n.t('to_group_can_not_be_on_same_location')
    end
    @move.errors.blank?
  end
  # rubocop:enable Metrics/AbcSize
end
