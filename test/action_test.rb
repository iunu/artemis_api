require "test_helper"

class ActionTest < Minitest::Test
  def setup
    options = {app_id: '12345',
               app_secret: '67890',
               base_uri: 'http://localhost:3000'}
    todays_date = DateTime.now
    @client = ArtemisApi::Client.new('ya29', 'eyJh', 7200, todays_date, options)

    stub_request(:get, 'http://localhost:3000/api/v3/facilities/2')
      .to_return(body: {data: {id: '2', type: 'facilities', attributes: {id: 2, name: 'Rare Dankness'}}}.to_json)
    @facility = ArtemisApi::Facility.find(2, @client)

    stub_request(:get, "http://localhost:3000/api/v3/facilities/#{@facility.id}/actions")
      .to_return(body: {data: [{id: '1', type: 'actions', attributes: {id: 1, action_type: 'start'}}, {id: '2', type: 'actions', attributes: {id: 2, action_type: 'move'}}]}.to_json)

    stub_request(:get, "http://localhost:3000/api/v3/facilities/#{@facility.id}/actions/2")
      .to_return(body: {data: {id: '2', type: 'actions', attributes: {id: 2, action_type: 'move'}}}.to_json)
  end

  def test_finding_all_actions
    actions = ArtemisApi::Action.find_all(@facility.id, @client)
    assert_equal 2, actions.count
  end

  def test_finding_a_specific_action
    action = ArtemisApi::Action.find(2, @facility.id, @client)
    assert_equal 'move', action.action_type
  end
end
