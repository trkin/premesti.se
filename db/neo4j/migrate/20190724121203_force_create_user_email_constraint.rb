class ForceCreateUserEmailConstraint < Neo4j::Migrations::Base
  def up
    say 'starting ForceCreateUserEmailConstraint'
    drop_index :User, :email, force: true
    say 'drop_index finished ForceCreateUserEmailConstraint'
    add_constraint :User, :email, force: true
    say 'add_constraint finished ForceCreateUserEmailConstraint'
  end

  def down
    drop_constraint :User, :email
  end
end
