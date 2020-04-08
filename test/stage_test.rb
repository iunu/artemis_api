require "test_helper"

class StageTest < Minitest::Test
  def setup
    get_client

    stub_request(:get, 'http://localhost:3000/api/v3/facilities/2')
      .to_return(body: {data: {id: '2', type: 'facilities', attributes: {id: 2, name: 'Rare Dankness'}}}.to_json)
    @facility = ArtemisApi::Facility.find(2, @client)

    stub_request(:get, "http://localhost:3000/api/v3/facilities/#{@facility.id}/stages")
      .to_return(body: {data: [{id: '1', type: 'stages', attributes: {id: 1, name: 'Growth', stage_type: 'growth'}}, {id: '2', type: 'stages', attributes: {id: 2, name: 'Stage 2', stage_type: 'stage_2'}}]}.to_json)

    stub_request(:get, "http://localhost:3000/api/v3/facilities/#{@facility.id}/stages/1")
      .to_return(body: {data: {id: '1', type: 'stages', attributes: {id: 1, name: 'Growth', stage_type: 'growth'}}}.to_json)
  end

  def test_finding_all_stages
    stages = ArtemisApi::Stage.find_all(@facility.id, @client)
    assert_equal 2, stages.count
  end

  def test_finding_all_stages_through_facility
    stages = @facility.stages
    assert_equal 2, stages.count
  end

  def test_finding_a_specific_stage
    stage = ArtemisApi::Stage.find(1, @facility.id, @client)
    assert_equal 'Growth', stage.name
    assert_equal 'growth', stage.stage_type
  end

  def test_finding_a_specific_stage_through_facility
    stage = @facility.find_stage(1)
    assert_equal 'Growth', stage.name
    assert_equal 'growth', stage.stage_type
  end
end
