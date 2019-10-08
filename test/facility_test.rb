require "test_helper"

class FacilityTest < Minitest::Test
  def setup
    get_client

    stub_request(:get, 'http://localhost:3000/api/v3/facilities')
      .to_return(body: {data: [{id: '1', type: 'facilities', attributes: {id: 1, name: 'Sky Fresh'}}, {id: '2', type: 'facilities', attributes: {id: 2, name: 'Rare Dankness'}}]}.to_json)
  end

  def test_finding_all_facilities
    facilities = ArtemisApi::Facility.find_all(client: @client)
    assert_equal 2, facilities.count
  end

  def test_finding_a_specific_facility
    stub_request(:get, 'http://localhost:3000/api/v3/facilities/2')
      .to_return(body: {data: {id: '2', type: 'facilities', attributes: {id: 2, name: 'Rare Dankness'}}}.to_json)

    facility = ArtemisApi::Facility.find(id: 2, client: @client)
    assert_equal 'Rare Dankness', facility.name
  end

  def test_finding_a_specific_facility_thats_already_in_memory
    ArtemisApi::Facility.find_all(client: @client)
    facility = ArtemisApi::Facility.find(id: 2, client: @client)
    assert_equal 'Rare Dankness', facility.name
  end
end
