require 'test_helper'
class Select2LocationsServiceTest < ActiveSupport::TestCase
  def result_ids_for_term(term, except_location_id = nil)
    results = Select2LocationsService.new(term, except_location_id).perform
    results.map { |r| r[:id] }
  end

  test 'filter by name' do
    city = create :city
    my_location = create :location, city: city, name: 'my_location_name'
    _another_location = create :location, city: city, name: 'another_location_name'
    assert_equal [my_location.id], result_ids_for_term('my_location_name')
    assert_equal [my_location.id], result_ids_for_term('y_location')
    assert_equal [my_location.id], result_ids_for_term('My_Location')
  end

  test 'filter by different language' do
    city = create :city
    my_location = create :location, city: city, name: 'my_location_name'
    _another_location = create :location, city: city, name: 'another_location_name'
    my_location.name_sr = 'мој_вртић'
    my_location['name_sr-latin'] = 'moj_vrtić'
    my_location.save!
    assert_equal [my_location.id], result_ids_for_term('my_location_name')
    assert_equal [my_location.id], result_ids_for_term('vrtić')
    assert_equal [my_location.id], result_ids_for_term('вртић')
  end

  test 'filter by uppercased cyrilic chars' do
    city = create :city
    my_location = create :location, city: city, name: 'Djurdjevak'
    _another_location = create :location, city: city, name: 'another_location_name'
    my_location.name_sr = 'Ђурђевак'
    my_location['name_sr-latin'] = 'Đurđevak'
    my_location.save!
    assert_equal [my_location.id], result_ids_for_term('dju')
    assert_equal [my_location.id], result_ids_for_term('Dju')
    assert_equal [my_location.id], result_ids_for_term('DJ')
    assert_equal [my_location.id], result_ids_for_term('ЂУ')
    assert_equal [my_location.id], result_ids_for_term('ђу')
    assert_equal [my_location.id], result_ids_for_term('ĐU')
    assert_equal [my_location.id], result_ids_for_term('đu')
  end

  test 'except_location_id' do
    city = create :city
    my_location = create :location, city: city, name: 'my_location_name'
    excepted_location = create :location, city: city, name: 'another_location_name'
    assert_equal [my_location.id, excepted_location.id].sort, result_ids_for_term('location_name').sort
    assert_equal [my_location.id], result_ids_for_term('location_name', excepted_location.id)
  end
end
