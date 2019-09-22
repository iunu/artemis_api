require "test_helper"

class HarvestUnitTest < Minitest::Test
  def setup
    get_client
    get_facility

    stub_request(:get, "http://localhost:3000/api/v3/facilities/#{@facility.id}/harvest_units")
      .to_return(body: {data: [{id: '1', type: 'harvest_units', attributes: {id: 1, name: 'pound', weight: 1}}, {id: '2', type: 'harvest_units', attributes: {id: 2, name: 'kilogram', weight: 2.2}}]}.to_json)

    stub_request(:get, "http://localhost:3000/api/v3/facilities/#{@facility.id}/harvest_units/2")
      .to_return(body: {data: {id: '2', type: 'harvest_units', attributes: {id: 2, name: 'kilogram', weight: 2.2}}}.to_json)
  end

  def test_finding_all_harvest_units
    harvest_units = ArtemisApi::HarvestUnit.find_all(@facility.id, @client)
    assert_equal 2, harvest_units.count
  end

  def test_finding_a_specific_harvest_unit
    harvest_unit = ArtemisApi::HarvestUnit.find(2, @facility.id, @client)
    assert_equal 'kilogram', harvest_unit.name
    assert_equal 2.2, harvest_unit.weight
  end
end
