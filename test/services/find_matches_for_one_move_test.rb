require 'test_helper'
class FindMatchesForOneMoveTest < ActiveSupport::TestCase
  def setup
    city = create :city
    l_a = create :location, city: city
    @g_a1 = create :group, age: 1, location: l_a
    @g_a2 = create :group, age: 2, location: l_a
    l_b = create :location, city: city
    @g_b1 = create :group, age: 1, location: l_b
    @g_b2 = create :group, age: 2, location: l_b
    l_c = create :location, city: city
    @g_c1 = create :group, age: 1, location: l_c
    l_d = create :location, city: city
    @g_d1 = create :group, age: 1, location: l_d
    l_e = create :location, city: city
    @g_e1 = create :group, age: 1, location: l_e
  end

  def test_ab_single
    # a -m_ab-> b
    #   <-m_ba-
    m_ab = create :move, from_group: @g_a1, to_groups: @g_b1
    m_ba = create :move, from_group: @g_b1, to_groups: @g_a1
    # some noice
    _m_ac = create :move, from_group: @g_a1, to_groups: @g_c1
    _m_ab2 = create :move, from_group: @g_a2, to_groups: @g_b2
    _m_ba2 = create :move, from_group: @g_b2, to_groups: @g_a2

    matches = [
      [m_ba]
    ]
    results = FindMatchesForOneMove.perform(m_ab)
    assert_equal matches, results
  end

  def test_ab_multiple
    # a -m_ab-> b
    #    <-m_ba1-
    #    <-m_ba2-
    #    <-m_ba3-
    # noice is to c since we are finding only m_ab
    # a -m_ac-> c
    #   <-m_ca-
    m_ab = create :move, from_group: @g_a1, to_groups: @g_b1, a_name: :m_ab
    m_ba1 = create :move, from_group: @g_b1, to_groups: @g_a1, a_name: :m_ba1
    m_ba2 = create :move, from_group: @g_b1, to_groups: @g_a1, a_name: :aaa
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
    assert_equal matches, results
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
    assert_equal matches, results
  end

  def test_abc_multiple
    # a -m_ab-> b -m_bc-> c
    #            <-m_ca1- c
    #            <-m_ca2- c
    #           b -m_bd-> d
    #             <-m_da- d
    # <-m_ea- e <-m_be- b
    # noice is adc since we are finding only for m_ab
    # a -m_ad-> d -m_dc-> c
    m_ab = create :move, from_group: @g_a1, to_groups: @g_b1, a_name: :m_ab
    m_bc = create :move, from_group: @g_b1, to_groups: @g_c1, a_name: :m_bc
    m_ca1 = create :move, from_group: @g_c1, to_groups: @g_a1, a_name: :m_ca1
    m_ca2 = create :move, from_group: @g_c1, to_groups: @g_a1, a_name: :m_ca2
    m_bd = create :move, from_group: @g_b1, to_groups: @g_d1, a_name: :m_bd
    m_da = create :move, from_group: @g_d1, to_groups: @g_a1, a_name: :m_da
    # ab is seond adge on e->a->b
    m_be = create :move, from_group: @g_b1, to_groups: @g_e1, a_name: :m_be
    m_ea = create :move, from_group: @g_e1, to_groups: @g_a1, a_name: :m_ea
    # some noice
    _m_ad = create :move, from_group: @g_a1, to_groups: @g_d1
    _m_dc = create :move, from_group: @g_d1, to_groups: @g_c1
    _m_ac = create :move, from_group: @g_a1, to_groups: @g_c1
    _m_ab2 = create :move, from_group: @g_a2, to_groups: @g_b2
    _m_ba2 = create :move, from_group: @g_b2, to_groups: @g_a2

    matches = [
      [m_ea, m_be],
      [m_da, m_bd],
      [m_ca2, m_bc],
      [m_ca1, m_bc],
    ]
    results = FindMatchesForOneMove.perform(m_ab)
    assert_equal matches, results
  end

  def test_abcd
    # a -m_ab-> b -m_bc-> c -m_cd-> d
    #                       <-m_da- d
    #             <-m_cb- c
    #   <-m_ba- b
    #           b -m_bd-> d -m_de-> e -m_ea-> a
    # noice is adc since we are finding only for m_ab
    # a -m_ad-> d -m_dc-> c
    # also when nodes repeats
    # a -m_ab-> b -m_ba-> a -m-ab-> b -b_ba-> a
    # TODO: Complete this and some mix tests

  end
end
