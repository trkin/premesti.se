class ChatsDatatable < TrkDatatables::Neo4j
  def columns
    {
      'chats.name': { title: Group.human_attribute_name(:name), search: false, order: false },
      'chats.status': { title: I18n.t('status'), select_options: Chat.statuses, search: false, order: false },
      'chats.created_at': { title: I18n.t('created_at') },
      '': { title: I18n.t('show') },
    }
  end

  def all_items
    Chat
      .as(:chats)
      .order(created_at: :desc)
  end

  def rows(filtered)
    filtered.map do |chat|
      label = I18n.t('show') + ' ' + chat.moves.size.to_s + ' ' + Move.model_name.human(count: chat.moves.size)
      actions = @view.link_to label, @view.public_chat_path(chat, chat.age_and_name_with_arrows_en)
      [
        chat.age_and_name_with_arrows,
        chat.status,
        chat.created_at.to_s(:long),
        actions,
      ]
    end
  end
end
