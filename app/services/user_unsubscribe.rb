class UserUnsubscribe
  class <<self
    def find_unsubscribe_type(tag)
      case tag
      when :new_match, :new_message
        :notifications_for_new_match
      else
        :notifications_for_news
      end
    end

    def generate_token(user_id, unsubscribe_type, data_for_token)
      Rails.application.message_verifier(:unsubscribe_generation).generate \
        [user_id, unsubscribe_type, data_for_token.to_json]
    end

    def user_id_unsubscribe_type_and_data_from_token(unsubscribe_token)
      user_id, unsubscribe_type, data_for_token = Rails.application.message_verifier(:unsubscribe_generation).verify \
        unsubscribe_token
      data = HashWithIndifferentAccess.new JSON.parse data_for_token if data_for_token.present?
      [user_id, unsubscribe_type, data]
    end
  end

  def initialize(user)
    @user = user
  end

  def perform(unsubscribe_type, data)
    msg = case unsubscribe_type.to_s.to_sym
          when :notifications_for_new_match
            raise 'there_is_no_move_data_for_notifications_for_new_match' if data[:move_id].blank?

            unsubscribe_from_new_match data
          when :notifications_for_news
            unsubscribe_from_news_mailing_list
          else
            raise "can_not_find_unsubscribe_type #{unsubscribe_type}"
          end
    Result.new msg
  end

  def unsubscribe_from_new_match(data)
    move = @user.moves.find_by id: data[:move_id]
    if move
      move.destroy_and_archive_chats 'added_move_by_mistake'
      ApplicationController.helpers.t_crud('success_delete', Move)
    elsif Move.where(id: data[:move_id]).present?
      I18n.t('this_move_does_not_belong_to_you')
    else
      I18n.t('this_move_was_deleted')
    end
  end

  def unsubscribe_from_news_mailing_list
    @user.subscribe_to_news_mailing_list = false
    @user.save!
    I18n.t('successfully_unsubscribed_from_item_name', item_name: I18n.t('notifications_for_news'))
  end
end
