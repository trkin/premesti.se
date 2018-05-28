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

  def move_share_link(move)
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
    link_to t('share'), uri.to_s, target: '_blank'
  end
end
