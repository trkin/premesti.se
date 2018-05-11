module FindMatchesInAllMoves
  def perform
    two_matches_query = %(
      MATCH (m1:Move)-[:CURRENT]-(current_g1:Group)-[:PREFER]-(m2:Move),
      (m2:Move)-[:CURRENT]-(current_g2:Group)-[:PREFER]-(m1:Move)
      RETURN m1, m2, current_g1, current_g2
    )
    two_matches = Neo4j::ActiveBase.current_session.query two_matches_query
    results = []
    two_matches.map do |r|
      results << [r.m1, r.m2]
    end

    three_matches_query = %(
      MATCH (m1:Move)-[:CURRENT]-(current_g1:Group)-[:PREFER]-(m2:Move),
      (m2:Move)-[:CURRENT]-(current_g2:Group)-[:PREFER]-(m3:Move),
      (m3:Move)-[:CURRENT]-(current_g3:Group)-[:PREFER]-(m1:Move)
      RETURN m1, m2, m3, current_g1, current_g2, current_g3
    )
    three_matches = Neo4j::ActiveBase.current_session.query three_matches_query
    three_matches.map do |r|
      results << [r.m1, r.m2, r.m3]
    end
    results
  end
  module_function :perform
end
