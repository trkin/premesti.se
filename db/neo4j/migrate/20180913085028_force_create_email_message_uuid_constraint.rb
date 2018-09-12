class ForceCreateEmailMessageUuidConstraint < Neo4j::Migrations::Base
  def up
    add_constraint :EmailMessage, :uuid, force: true
  end

  def down
    drop_constraint :EmailMessage, :uuid
  end
end
