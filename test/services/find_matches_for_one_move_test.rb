require 'test_helper'
class FindMatchesForOneMoveTest < ActiveSupport::TestCase
  def setup
    city = create :city
    l_a = create :location, city: city
    @g_a1 = create :group, age: 1, location: l_a, name: 'a1'
    @g_a2 = create :group, age: 2, location: l_a, name: 'a2'
    l_b = create :location, city: city
    @g_b1 = create :group, age: 1, location: l_b, name: 'b1'
    @g_b2 = create :group, age: 2, location: l_b, name: 'b2'
    l_c = create :location, city: city
    @g_c1 = create :group, age: 1, location: l_c, name: 'c1'
    l_d = create :location, city: city
    @g_d1 = create :group, age: 1, location: l_d, name: 'd1'
    l_e = create :location, city: city
    @g_e1 = create :group, age: 1, location: l_e, name: 'e1'
  end

  def test_empty_results
    m_ab = create :move, from_group: @g_a1, to_groups: @g_b1, a_name: :m_ab
    matches = []
    results = FindMatchesForOneMove.perform(m_ab)
    assert_equal (matches.map { |r| r.map(&:a_name) }), (results.map { |r| r.map(&:a_name) })
  end

  def test_ab_user_a_not_confirmed
    # a -m_ab-> b
    #   <-m_ba-
    unconfirmed_user = create :unconfirmed_user
    m_ab = create :move, from_group: @g_a1, to_groups: @g_b1, a_name: :m_ab, user: unconfirmed_user
    _m_ba = create :move, from_group: @g_b1, to_groups: @g_a1, a_name: :m_ba

    matches = []
    results = FindMatchesForOneMove.perform(m_ab)
    assert_equal (matches.map { |r| r.map(&:a_name) }), (results.map { |r| r.map(&:a_name) })
  end

  def test_ab_user_b_not_confirmed
    # a -m_ab-> b
    #   <-m_ba-
    unconfirmed_user = create :unconfirmed_user
    m_ab = create :move, from_group: @g_a1, to_groups: @g_b1, a_name: :m_ab
    _m_ba = create :move, from_group: @g_b1, to_groups: @g_a1, user: unconfirmed_user, a_name: :m_ba

    matches = []
    results = FindMatchesForOneMove.perform(m_ab)
    assert_equal (matches.map { |r| r.map(&:a_name) }), (results.map { |r| r.map(&:a_name) })
  end

  def test_ab_single
    # a -m_ab-> b
    #   <-m_ba-
    m_ab = create :move, from_group: @g_a1, to_groups: @g_b1, a_name: :m_ab
    m_ba = create :move, from_group: @g_b1, to_groups: @g_a1, a_name: :m_ba
    # some noice
    _m_ac = create :move, from_group: @g_a1, to_groups: @g_c1
    _m_ab2 = create :move, from_group: @g_a2, to_groups: @g_b2
    _m_ba2 = create :move, from_group: @g_b2, to_groups: @g_a2

    matches = [
      [m_ba]
    ]
    results = FindMatchesForOneMove.perform(m_ab)
    assert_equal (matches.map { |r| r.map(&:a_name) }), (results.map { |r| r.map(&:a_name) })
  end

  def test_ab_multiple
    # a -m_ab-> b
    #    <-m_ba1-
    #    <-m_ba2-
    #    <-m_ba3-
    # noice is to c since we are finding only m_ab, and there should not be
    # repetition like two times traverse one location
    # a -m_ac-> c
    #   <-m_ca-
    m_ab = create :move, from_group: @g_a1, to_groups: @g_b1, a_name: :m_ab
    m_ba1 = create :move, from_group: @g_b1, to_groups: @g_a1, a_name: :m_ba1
    m_ba2 = create :move, from_group: @g_b1, to_groups: @g_a1, a_name: :m_ba2
    m_ba3 = create :move, from_group: @g_b1, to_groups: @g_a1, a_name: :m_ba3
    # some noice
    _m_ac = create :move, from_group: @g_a1, to_groups: @g_c1, a_name: :m_ac
    _m_ca = create :move, from_group: @g_c1, to_groups: @g_a1, a_name: :m_ca
    _m_ab2 = create :move, from_group: @g_a2, to_groups: @g_b2
    _m_ba2 = create :move, from_group: @g_b2, to_groups: @g_a2

    matches = [
      [m_ba3], [m_ba2], [m_ba1]
    ]
    results = FindMatchesForOneMove.perform(m_ab)
    assert_equal (matches.map { |r| r.map(&:a_name) }), (results.map { |r| r.map(&:a_name) })
  end

  def test_abc_single
    # a -m_ab-> b -m_bc-> c
    #        <-m_ca-
    # noice is adc since we are finding only for m_ab
    # a -m_ad-> d -m_dc-> c
    m_ab = create :move, from_group: @g_a1, to_groups: @g_b1, a_name: :m_ab
    m_bc = create :move, from_group: @g_b1, to_groups: @g_c1, a_name: :m_bc
    m_ca = create :move, from_group: @g_c1, to_groups: @g_a1, a_name: :m_ca
    # some noice
    _m_ad = create :move, from_group: @g_a1, to_groups: @g_d1
    _m_dc = create :move, from_group: @g_d1, to_groups: @g_c1
    _m_ab2 = create :move, from_group: @g_a2, to_groups: @g_b2
    _m_ba2 = create :move, from_group: @g_b2, to_groups: @g_a2

    matches = [
      [m_ca, m_bc]
    ]
    results = FindMatchesForOneMove.perform(m_ab)
    assert_equal (matches.map { |r| r.map(&:a_name) }), (results.map { |r| r.map(&:a_name) })
  end

  def test_abc_multiple
    # a -m_ab-> b -m_bc-> c
    #            <-m_ca1- c
    #            <-m_ca2- c
    #           b -m_bd-> d
    #             <-m_da- d
    # noice is adc since we are finding only for m_ab
    # c -m_ce-> e -m_ec-> c
    m_ab = create :move, from_group: @g_a1, to_groups: @g_b1, a_name: :m_ab
    m_bc = create :move, from_group: @g_b1, to_groups: @g_c1, a_name: :m_bc
    m_ca1 = create :move, from_group: @g_c1, to_groups: @g_a1, a_name: :m_ca1
    m_ca2 = create :move, from_group: @g_c1, to_groups: @g_a1, a_name: :m_ca2
    m_bd = create :move, from_group: @g_b1, to_groups: @g_d1, a_name: :m_bd
    m_da = create :move, from_group: @g_d1, to_groups: @g_a1, a_name: :m_da
    # some noice
    _m_ce = create :move, from_group: @g_c1, to_groups: @g_e1, a_name: '_m_ce'
    _m_ec = create :move, from_group: @g_e1, to_groups: @g_c1, a_name: '_m_ec'
    _m_ac = create :move, from_group: @g_a1, to_groups: @g_c1, a_name: '_m_ac'
    _m_ab2 = create :move, from_group: @g_a2, to_groups: @g_b2, a_name: '_m_ab2'
    _m_ba2 = create :move, from_group: @g_b2, to_groups: @g_a2, a_name: '_m_ba2'

    matches = [
      [m_da, m_bd],
      [m_ca2, m_bc],
      [m_ca1, m_bc],
    ]
    results = FindMatchesForOneMove.perform(m_ab)
    assert_equal (matches.map { |r| r.map(&:a_name) }), (results.map { |r| r.map(&:a_name) })
  end

  def test_various
    # a <-m_ba- b
    # a -m_ab-> b -m_bc-> c -m_cd-> d
    #               a <-m_da- d
    #           b <-m_cb- c
    #           b -m_bd-> d -m_de-> e -m_ea-> a
    # noise is for different direction using m_ba (not using m_ab)
    # a -m_ad-> d -m_dc-> c -m_cb-> b
    #
    m_ab = create :move, from_group: @g_a1, to_groups: @g_b1, a_name: :m_ab
    _m_ad = create :move, from_group: @g_a1, to_groups: @g_d1, a_name: :m_ad
    m_ba = create :move, from_group: @g_b1, to_groups: @g_a1, a_name: :m_ba
    m_bc = create :move, from_group: @g_b1, to_groups: @g_c1, a_name: :m_bc
    m_cd = create :move, from_group: @g_c1, to_groups: @g_d1, a_name: :m_cd
    m_da = create :move, from_group: @g_d1, to_groups: @g_a1, a_name: :m_da
    _m_dc = create :move, from_group: @g_d1, to_groups: @g_c1, a_name: :m_dc
    _m_cb = create :move, from_group: @g_c1, to_groups: @g_b1, a_name: :m_cb
    m_bd = create :move, from_group: @g_b1, to_groups: @g_d1, a_name: :m_bd
    m_de = create :move, from_group: @g_d1, to_groups: @g_e1, a_name: :m_de
    m_ea = create :move, from_group: @g_e1, to_groups: @g_a1, a_name: :m_ea
    matches = [
      [m_ba],
      [m_da, m_bd],
      [m_ea, m_de, m_bd],
      [m_da, m_cd, m_bc],
      [m_ea, m_de, m_cd, m_bc],
    ]
    results = FindMatchesForOneMove.perform(m_ab)
    assert_equal (matches.map { |r| r.map(&:a_name) }), (results.map { |r| r.map(&:a_name) })
  end

  # a -m_abcd-> b
  #         \-> c -m_ca-> a
  #         \-> d
  # noice because of we target edge a-c, so rotation ab-ba is not affected
  # b -m_ba -> a
  def test_ab_multigroups
    m_abcd = create :move, from_group: @g_a1, to_groups: [@g_b1, @g_c1, @g_d1], a_name: :m_abcd
    m_ca = create :move, from_group: @g_c1, to_groups: [@g_a1], a_name: :m_ca
    _m_ba = create :move, from_group: @g_b1, to_groups: [@g_a1], a_name: :m_ba
    matches = [
      [m_ca],
    ]
    results = FindMatchesForOneMove.perform(m_abcd, @g_c1)
    assert_equal (matches.map { |r| r.map(&:a_name) }), (results.map { |r| r.map(&:a_name) })
  end

  # a -m_abcd-> b
  #         \-> c -m_cba-> b
  #         \-> d      \-> a
  # b -m_ba -> a
  # noice because we target a-c
  # d -m_dc-> c
  #
  def test_various_multigroups
    m_abcd = create :move, from_group: @g_a1, to_groups: [@g_b1, @g_c1, @g_d1], a_name: :m_abcd
    m_cba = create :move, from_group: @g_c1, to_groups: [@g_b1, @g_a1], a_name: :m_cba
    m_ba = create :move, from_group: @g_b1, to_groups: [@g_a1], a_name: :m_ba
    _m_dc = create :move, from_group: @g_d1, to_groups: [@g_c1], a_name: :m_dc
    matches = [
      [m_cba],
      [m_ba, m_cba],
    ]
    results = FindMatchesForOneMove.perform(m_abcd, @g_c1)
    assert_equal (matches.map { |r| r.map(&:a_name) }), (results.map { |r| r.map(&:a_name) })
  end
end
