class ForceCreateMessageStatusIndex < Neo4j::Migrations::Base
  def up
    add_index :Message, :status, force: true
  end

  def down
    drop_index :Message, :status
  end
end
