require "test_helper"

class SeedingUnitTest < Minitest::Test
  def setup
    get_client
    get_facility

    stub_request(:get, "http://localhost:3000/api/v3/facilities/#{@facility.id}/seeding_units")
      .to_return(body: {data: [{id: '1', type: 'seeding_units', attributes: {id: 1, name: 'board'}}, {id: '2', type: 'seeding_units', attributes: {id: 2, name: 'raft'}}]}.to_json)

    stub_request(:get, "http://localhost:3000/api/v3/facilities/#{@facility.id}/seeding_units/2")
      .to_return(body: {data: {id: '2', type: 'seeding_units', attributes: {id: 2, name: 'raft'}}}.to_json)
  end

  def test_finding_all_seeding_units
    seeding_units = ArtemisApi::SeedingUnit.find_all(@facility.id, @client)
    assert_equal 2, seeding_units.count
  end

  def test_finding_a_specific_seeding_unit
    seeding_unit = ArtemisApi::SeedingUnit.find(2, @facility.id, @client)
    assert_equal 'raft', seeding_unit.name
  end
end
