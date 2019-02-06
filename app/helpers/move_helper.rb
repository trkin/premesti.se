module MoveHelper
  def move_static_map_url(move)
    show_static_lines_map_url(
      move.from_group.location,
      move.to_groups.map(&:location),
      color: "0x#{Constant::AGE_COLORS[move.from_group.age - 1][1..-1]}",
    )
  end

  def move_static_map(move)
    image_tag move_static_map_url(move), class: 'show-lines-map-container'
  end

  def move_share_link(move, opts = {})
    uri = URI::HTTP.build(
      host: 'www.facebook.com',
      path: '/sharer/sharer.php',
      query: {
        s: 100,
        p: {
          url: my_move_url(move, move.group_age_and_locations),
          images: [
            move_static_map_url(move),
          ],
        }
      }.to_query
    )

    link_to t('share_on_facebook').html_safe, uri.to_s, { target: '_blank' }.merge(opts)
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
