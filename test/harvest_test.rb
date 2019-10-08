require "test_helper"

class HarvestTest < Minitest::Test
  def setup
    get_client
    get_facility

    stub_request(:get, "http://localhost:3000/api/v3/facilities/#{@facility.id}/harvests")
      .to_return(body: {data: [{id: '1', type: 'harvests', attributes: {id: 1, quantity: 4, harvest_type: 'complete'}}, {id: '2', type: 'harvests', attributes: {id: 2, quantity: 1, harvest_type: 'partial'}}]}.to_json)

    stub_request(:get, "http://localhost:3000/api/v3/facilities/#{@facility.id}/harvests/2")
      .to_return(body: {data: {id: '2', type: 'harvests', attributes: {id: 2, quantity: 1, harvest_type: 'partial'}}}.to_json)
  end

  def test_finding_all_harvests
    harvests = ArtemisApi::Harvest.find_all(facility_id: @facility.id, client: @client)
    assert_equal 2, harvests.count
  end

  def test_finding_a_specific_harvest
    harvest = ArtemisApi::Harvest.find(id: 2, facility_id: @facility.id, client: @client)
    assert_equal 'partial', harvest.harvest_type
    assert_equal 1, harvest.quantity
  end
end
