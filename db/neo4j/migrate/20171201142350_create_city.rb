class CreateCity < Neo4j::Migrations::Base
  def up
    add_constraint :City, :uuid
  end

  def down
    drop_constraint :City, :uuid
  end
end
