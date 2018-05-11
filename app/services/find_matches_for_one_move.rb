module FindMatchesForOneMove
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

    (3..3).each do |i|
      query_for_i = ''
      pluck = []
      1.upto(i-1).each do |j|
        query_for_i << "(m#{j}:Move)-[:CURRENT]-(current_g_#{j}:Group)-[:PREFER]-(m#{j+1}:Move),"
        pluck << "m#{j+1}"
      end
      query_for_i << "(m#{i}:Move)-[:CURRENT]-(current_g_#{i}:Group)-[:PREFER]-(m#{1}:Move)"
      results_for_i = move.query_as(:m1).match(query_for_i).pluck(pluck)
      results_for_i.map do |r|
        results << r
      end
    end
    results
  end
  module_function :perform
end
