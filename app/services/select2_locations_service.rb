class Select2LocationsService
  def initialize(term, except_location_id = nil)
    @term = term
    @except_location_id = except_location_id
  end

  def perform
    query = I18n.available_locales.map do |locale|
      "location.`name_#{locale}` =~ {term}"
    end.join(' OR ')
    results = Location.query_as(:location)
                      .where(query)
                      .params(term: "(?iu).*#{@term}.*")
    results = results.where("location.uuid <> '#{@except_location_id}'") if @except_location_id.present?
    results.pluck(:location).map do |location|
      { id: location.id, text: location.name_with_address }
    end
  end
end
