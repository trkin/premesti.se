class MatchedGroups
  include Neo4j::ActiveRel

  from_class :Chat
  to_class :Group
  # type :MATCHED_GROUPS # this is inherited from class name

  # from 0 to N-1
  property :order, type: Integer

  validates_presence_of :order

  creates_unique
end
