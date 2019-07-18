require "test_helper"

class ZoneTest < Minitest::Test
  def setup
    options = {app_id: '12345',
               app_secret: '67890',
               base_uri: 'http://localhost:3000'}
    todays_date = DateTime.now
    @client = ArtemisApi::Client.new('ya29', 'eyJh', 7200, todays_date, options)

    stub_request(:get, 'http://localhost:3000/api/v3/facilities/2')
      .to_return(body: {data: {id: '2', type: 'facilities', attributes: {id: 2, name: 'Rare Dankness'}}}.to_json)
    @facility = ArtemisApi::Facility.find(2, @client)

    stub_request(:get, "http://localhost:3000/api/v3/facilities/#{@facility.id}/zones")
      .to_return(body: {data: [{id: '1', type: 'zones', attributes: {id: 1, name: 'Germination'}}, {id: '2', type: 'zones', attributes: {id: 2, name: 'Propagation'}}]}.to_json)

    stub_request(:get, "http://localhost:3000/api/v3/facilities/#{@facility.id}/zones/2")
      .to_return(body: {data: {id: '2', type: 'zones', attributes: {id: 2, name: 'Propagation'}}}.to_json)
  end

  def test_finding_all_zones
    zones = ArtemisApi::Zone.find_all(@facility.id, @client)
    assert_equal 2, zones.count
  end

  def test_finding_all_zones_through_facility
    zones = @facility.zones
    assert_equal 2, zones.count
  end

  def test_finding_a_specific_zone
    zone = ArtemisApi::Zone.find(2, @facility.id, @client)
    assert_equal 'Propagation', zone.name
  end

  def test_finding_a_specific_zone_through_facility
    zone = @facility.find_zone(2)
    assert_equal 'Propagation', zone.name
  end
end
