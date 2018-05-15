module FindMatchesForOneMove
  MAX_LENGTH_OF_THE_ROTATION = 10
  # rubocop:disable Metrics/MethodLength
  # rubocop:disable Metrics/AbcSize
  def perform(move)
    results = []

    query_for_ab = %(
      (a:Move)-[:CURRENT]-(current_g_a:Group)-[:PREFER]-(b:Move),
      (b:Move)-[:CURRENT]-(current_g_b:Group)-[:PREFER]-(a:Move)
    )
    results_ab = move.query_as(:a).match(query_for_ab).pluck(:b)
    results_ab.map do |b|
      results << [b]
    end

    # this just for reference... we use query_for_i
    # query_for_abc = %(
    #   (a:Move)-[:CURRENT]-(current_g_a:Group)-[:PREFER]-(b:Move),
    #   (b:Move)-[:CURRENT]-(current_g_b:Group)-[:PREFER]-(c:Move),
    #   (c:Move)-[:CURRENT]-(current_g_c:Group)-[:PREFER]-(a:Move)
    # )
    # results_abc = move.query_as(:a).match(query_for_abc).pluck(:b, :c)

    # results_abc.map do |b, c|
    #   results << [b, c]
    # end

    (3..MAX_LENGTH_OF_THE_ROTATION).each do |i|
      query_for_i = ''
      pluck = []
      1.upto(i - 1).each do |j|
        query_for_i << "(m#{j}:Move)-[:CURRENT]-(current_g_#{j}:Group)-[:PREFER]-(m#{j + 1}:Move),"
        pluck << "m#{j + 1}"
      end
      query_for_i << "(m#{i}:Move)-[:CURRENT]-(current_g_#{i}:Group)-[:PREFER]-(m1:Move)"
      # node should not repeat in matching circle
      query_for_node_difference = 'true'
      1.upto(i).each do |j|
        j.upto(i).each do |jj|
          next if j == jj
          query_for_node_difference << " AND current_g_#{j} <> current_g_#{jj}"
        end
      end

      # rubocop disable Layout/SpaceInsideStringInterpolation
      # puts "\nMATCH (m1), #{query_for_i} WHERE m1.uuid = '#{move.id}' AND #{query_for_node_difference} \
      # RETURN m1, #{pluck.join(', ')}, #{ 1.upto(i).map { |j| "current_g_#{j}" }.join(', ') } "

      results_for_i = move.query_as(:m1).match(query_for_i).where(query_for_node_difference).pluck(pluck)
      results_for_i.map do |r|
        results << r
      end
    end
    results
  end
  module_function :perform
end
