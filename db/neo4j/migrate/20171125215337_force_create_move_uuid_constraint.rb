class ForceCreateMoveUuidConstraint < Neo4j::Migrations::Base
  def up
    add_constraint :Move, :uuid, force: true
  end

  def down
    drop_constraint :Move, :uuid
  end
end
