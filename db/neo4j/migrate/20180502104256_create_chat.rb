class CreateChat < Neo4j::Migrations::Base
  def up
    add_constraint :Chat, :uuid, force: true
  end

  def down
    drop_constraint :Chat, :uuid
  end
end
