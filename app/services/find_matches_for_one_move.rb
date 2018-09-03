module FindMatchesForOneMove
  # you can override for specific test cases
  MAX_LENGTH_OF_THE_ROTATION = Rails.env.test? ? 2 : 6
  # rubocop:disable Metrics/MethodLength
  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/PerceivedComplexity
  # result to moveAB and group
  # [
  #   [mBA],
  #   [mCA, mBC],
  # ]
  def perform(move, target_group: nil, max_length_of_the_rotation: MAX_LENGTH_OF_THE_ROTATION)
    max_length_of_the_rotation = MAX_LENGTH_OF_THE_ROTATION if max_length_of_the_rotation.nil?
    if move.to_groups.length == 1 || target_group.nil?
      target_group = move.to_groups.first
    else
      move.to_groups.find target_group
    end
    results = []

    # this just for reference... we use query_for_i
    # query_for_ab = %(
    #   (a:Move)-[:CURRENT]-(current_g_a:Group)-[:PREFER]-(b:Move),
    #   (b:Move)-[:CURRENT]-(current_g_b:Group)-[:PREFER]-(a:Move)
    # )
    # results_ab = move.query_as(:a).match(query_for_ab).pluck(:b)
    # results_ab.map do |b|
    #   results << [b]
    # end
    # query_for_abc = %(
    #   (a:Move)-[:CURRENT]-(current_g_a:Group)-[:PREFER]-(b:Move),
    #   (b:Move)-[:CURRENT]-(current_g_b:Group)-[:PREFER]-(c:Move),
    #   (c:Move)-[:CURRENT]-(current_g_c:Group)-[:PREFER]-(a:Move)
    # )
    # results_abc = move.query_as(:a).match(query_for_abc).pluck(:b, :c)

    # results_abc.map do |b, c|
    #   results << [b, c]
    # end

    # rubocop:disable Metrics/BlockLength
    (2..max_length_of_the_rotation).each do |i|
      match_for_i = ''
      match_for_unconfirmed_user = ''
      pluck = []
      1.upto(i - 1).each do |j|
        match_for_i << "(m#{j}:Move)-[:CURRENT]-(current_g_#{j}:Group)-[:PREFER]-(m#{j + 1}:Move),"
        match_for_unconfirmed_user << "(m#{j}:Move)-[:WANTS]-(u#{j}:User),"
        pluck << "m#{j + 1}"
      end
      match_for_i << "(m#{i}:Move)-[:CURRENT]-(current_g_#{i}:Group)-[:PREFER]-(m1:Move)"
      match_for_unconfirmed_user << "(m#{i}:Move)-[:WANTS]-(u#{i}:User)"
      # node should not repeat in matching circle
      query_for_node_difference = 'true'
      query_for_uncofirmed_user = 'true'
      1.upto(i).each do |j|
        query_for_uncofirmed_user << " AND u#{j}.confirmed_at IS NOT NULL"
        j.upto(i).each do |jj|
          next if j == jj
          query_for_node_difference << " AND current_g_#{j} <> current_g_#{jj}"
        end
      end
      # preferred group must match first move preffered_group
      # TODO: this is too slow, probably because of using where on 2 nodes...
      # try if using one 'where' on edge would be better
      query_for_move_preferred_group = "current_g_#{i}.uuid = '#{target_group.id}'"

      # rubocop disable Layout/SpaceInsideStringInterpolation
      # rubocop:disable Metrics/LineLength
      # puts "copy_to_console\nMATCH (m1), #{match_for_i} WHERE m1.uuid = '#{move.id}' AND #{query_for_node_difference} AND #{query_for_move_preferred_group} \
      # RETURN m1, #{pluck.join(', ')}, #{ 1.upto(i).map { |j| "current_g_#{j}" }.join(', ') } "
      # rubocop:enable Metrics/LineLength

      start_time = Time.current
      query_for_i = move.query_as(:m1)
                        .match(match_for_i)
                        .match(match_for_unconfirmed_user)
                        .where(query_for_node_difference)
                        .where(query_for_move_preferred_group)
                        .where(query_for_uncofirmed_user)
      results_for_i = query_for_i.pluck(pluck)
      # puts "cypher\n#{results_for_i.to_cypher}"
      spent_time = Time.current - start_time
      if spent_time > 2
        printf "i=#{i} %.2fs ", spent_time
      else
        printf '.'
      end
      results_for_i.map do |r|
        results << if i == 2 # r.array? == false
                     [r]
                   else
                     r
                   end
      end
    end
    # rubocop:enable Metrics/BlockLength
    results
  end
  # rubocop:enable Metrics/MethodLength
  # rubocop:enable Metrics/AbcSize
  # rubocop:enable Metrics/PerceivedComplexity
  module_function :perform
end
