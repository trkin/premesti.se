# https://stackoverflow.com/questions/20329387/how-to-assert-the-contents-of-an-array-indifferent-of-the-ordering
module MiniTest::Assertions
  ##
  # Fails unless <tt>exp</tt> and <tt>act</tt> are both arrays and
  # contain the same elements which are sorted by :id
  #
  #     assert_matched_arrays [user3,user2,user1], [user1,user2,user3]
  #     assert_matched_arrays [[user3,user2,user1]], [[user1,user2,user3]]

  def assert_equal_when_sorted_by_id(exp, act)
    exp_ary = exp.to_ary
    assert_kind_of Array, exp_ary
    act_ary = act.to_ary
    assert_kind_of Array, act_ary
    if exp_ary.first.class == Array
      exp_ary.zip(act_ary).each do |e, a|
        assert_equal e.sort_by(&:id), a.sort_by(&:id)
      end
    else
      assert_equal exp_ary.sort_by(&:id), act_ary.sort_by(&:id)
    end
  end
end
