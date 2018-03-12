require 'test_helper'

class MovesControllerTest < ActionDispatch::IntegrationTest
  def create_move_and_sign_in
    move = create :move
    sign_in move.user
    move
  end

  test 'show' do
    move = create_move_and_sign_in
    get move_path(move)
    assert_select 'h1', /#{move.from_group.location.name}/
  end

  test 'delete to_group' do
    move = create_move_and_sign_in
    group = create :group
    move.to_groups << group

    assert_difference "move.to_groups.count", -1 do
      delete destroy_to_group_move_path(move, to_group_id: group.id)
    end
  end

  test 'create to_group' do
    move = create_move_and_sign_in
    group = create :group, age: move.from_group.age
    assert_difference "move.to_groups.count", 1 do
      post create_to_group_move_path(move, to_location_id: group.location.id)
    end
    follow_redirect!
    assert response.body.include? group.location.name
  end
end
