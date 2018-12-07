# https://stackoverflow.com/questions/20329387/how-to-assert-the-contents-of-an-array-indifferent-of-the-ordering
module MiniTest::Assertions
  # Fails unless <tt>exp</tt> and <tt>act</tt> are both arrays and
  # contain the same elements which are sorted by :id
  #
  #     assert_equal_when_sorted_by_id [user3,user2,user1], [user1,user2,user3]
  #     assert_equal_when_sorted_by_id [[user3,user2,user1]], [[user1,user2,user3]]

  def assert_equal_when_sorted_by_id(exp, act)
    exp_ary = exp.to_ary
    assert_kind_of Array, exp_ary
    act_ary = act.to_ary
    assert_kind_of Array, act_ary
    assert_equal exp_ary.size, act_ary.size
    if exp_ary.first.class == Array
      exp_ary.zip(act_ary).each do |e, a|
        assert_equal e.sort_by(&:id), a.sort_by(&:id)
      end
    else
      assert_equal exp_ary.sort_by(&:id), act_ary.sort_by(&:id)
    end
  end

  # Fails unless <tt>exp</tt> and <tt>act</tt> are both arrays and
  # contain the same elements which are sorted by [:id]
  #
  #     assert_equal_when_sorted_by_key [{id: 1}, {id: 2}], [{id: 2}, {id: 1}]

  def assert_equal_when_sorted_by_key(exp, act, default_key: :id)
    exp_ary = exp.to_ary
    assert_kind_of Array, exp_ary
    act_ary = act.to_ary
    assert_kind_of Array, act_ary
    assert_equal exp_ary.size, act_ary.size
    assert_equal (exp_val.sort_by { |i| i[default_key] }), (act_val.sort_by { |i| i[default_key] })
  end


  # Fails unless <tt>exp</tt> and <tt>act</tt> are both arrays and
  # contain the same elements which are sorted by [:id] or other key
  #
  #     assert_equal_hash_when_sorted_by_key {'1': [{id: 1}, {id: 2}]}, {'1': [{id: 2}, {id: 1}]}

  def assert_equal_hash_when_values_are_sorted_by_key(exp, act, default_key: :id)
    assert_kind_of Hash, exp
    assert_kind_of Hash, act
    assert_equal exp.size, act.size
    if exp.empty?
      assert_empty act
    else
      exp.sort.zip(act.sort).each do |(exp_key, exp_val),(act_key, act_val)|
        assert_equal exp_key, act_key
        assert_equal (exp_val.sort_by { |i| i[default_key] }), (act_val.sort_by { |i| i[default_key] })
      end
    end
  end
end
