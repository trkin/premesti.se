module MoveHelper
  #  image_tag move_static_map_url(move), class: 'show-lines-map-container'
  def move_static_map_url(move)
    show_static_lines_map_url(
      move.from_group.location,
      move.to_groups.map(&:location),
      color: "0x#{Constant::AGE_COLORS[move.from_group.age - 1][1..-1]}",
    )
  end

  # image_tag chat_static_map_url(chat)
  def chat_static_map_url(chat)
    locations = chat.ordered_groups.map(&:location)
    show_static_circle_map_url locations
  end

  # This is url based share, but here we can not receive response
  # def move_share_link(move, opts = {})
  #   uri = URI::HTTP.build(
  #     host: 'www.facebook.com',
  #     path: '/sharer/sharer.php',
  #     query: {
  #       u: public_move_url(move, move.group_age_and_locations),
  #       # s: 100,
  #       # p: {
  #       #   url: public_move_url(move, move.group_age_and_locations),
  #       #   images: [
  #       #     move_static_map_url(move),
  #       #   ],
  #       # }
  #     }.to_query
  #   )
  #   link_to t('share_on_facebook').html_safe, uri.to_s, { target: '_blank' }.merge(opts)
  # end

  # This is javascript based share
  def move_share_link(move, options = {})
    options['data-facebook-share'] = public_move_url(move, move.group_age_and_locations),
    options['data-facebook-model-id'] = "move_id:#{move.id}"
    options['data-facebook-success-link'] = move_path(move)
    text = <<~HERE_DOC
    <span class='d-none d-sm-inline'>#{t('share_on_facebook')}</span>
    <span class='d-sm-none'>#{t('share_facebook')}</span>
    HERE_DOC
    link_to text.html_safe, '#', options
  end

  def chat_share_link(chat, options = {})
    options['data-facebook-share'] = public_chat_url(chat, chat.name_with_arrows)
    options['data-facebook-model-id'] = "chat_id:#{chat.id}"
    options['data-facebook-success-link'] = chat_path(chat)
    link_to t('share_on_facebook').html_safe, '#', options
  end

  def latest_move_timestamp
    return @latest_move_timestamp if @latest_move_timestamp.present?

    @latest_move_timestamp = Neo4j::ActiveBase.current_session.query('MATCH (n:Move) RETURN max(n.updated_at) AS m').first.m
  end

  def latest_chat_timestamp
    return @latest_chat_timestamp if @latest_chat_timestamp.present?

    @latest_chat_timestamp = Neo4j::ActiveBase.current_session.query('MATCH (n:Chat) RETURN max(n.updated_at) AS m').first.m
  end
end
