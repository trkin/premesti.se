class ForceCreateUserStatusIndex < Neo4j::Migrations::Base
  def up
    add_index :User, :status, force: true
  end

  def down
    drop_index :User, :status
  end
end
