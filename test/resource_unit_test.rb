require "test_helper"

class ResourceUnitTest < Minitest::Test
  def setup
    get_client
    get_facility

    stub_request(:get, "http://localhost:3000/api/v3/facilities/#{@facility.id}/resource_units")
      .to_return(body: {data: [{id: '1', type: 'resource_units', attributes: {id: 1, name: 'Bunch', kind: 'count', conversion_si: 1.0}}, {id: '2', type: 'resource_units', attributes: {id: 2, name: 'grams', kind: 'weight', conversion_si: 1.0}}]}.to_json)

    stub_request(:get, "http://localhost:3000/api/v3/facilities/#{@facility.id}/resource_units/2")
      .to_return(body: {data: {id: '2', type: 'resource_units', attributes: {id: 2, name: 'grams', kind: 'weight', conversion_is: 1.0}}}.to_json)
  end

  def test_finding_all_resource_units
    resource_units = ArtemisApi::ResourceUnit.find_all(facility_id: @facility.id, client: @client)
    assert_equal 2, resource_units.count
  end

  def test_finding_a_specific_resource_unit
    resource_unit = ArtemisApi::ResourceUnit.find(id: 2, facility_id: @facility.id, client: @client)
    assert_equal 'grams', resource_unit.name
  end
end
