class ForceCreateChatStatusIndex < Neo4j::Migrations::Base
  def up
    add_index :Chat, :status, force: true
  end

  def down
    drop_index :Chat, :status
  end
end
