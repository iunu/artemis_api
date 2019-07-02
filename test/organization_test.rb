require "test_helper"

class OrganizationTest < Minitest::Test
  def setup
    options = {app_id: '12345',
               app_secret: '67890',
               base_uri: 'http://localhost:3000'}
    @client = ArtemisApi::Client.new('ya29', 'eyJh', options)

    stub_request(:get, 'http://localhost:3000/api/v3/organizations')
      .to_return(body: {data: [{id: '1', type: 'organizations', attributes: {id: 1, name: 'Sky Fresh'}}, {id: '2', type: 'organizations', attributes: {id: 2, name: 'Rare Dankness'}}]}.to_json)
  end

  def test_finding_all_organizations
    organizations = ArtemisApi::Organization.find_all(@client)
    assert_equal 2, organizations.count
  end

  def test_finding_a_specific_organization
    stub_request(:get, 'http://localhost:3000/api/v3/organizations/2')
      .to_return(body: {data: {id: '2', type: 'organizations', attributes: {id: 2, name: 'Rare Dankness'}}}.to_json)

    org = ArtemisApi::Organization.find(2, @client)
    assert_equal 'Rare Dankness', org.name
  end

  def test_finding_a_specific_org_thats_already_in_memory
    ArtemisApi::Organization.find_all(@client)
    org = ArtemisApi::Organization.find(2, @client)
    assert_equal 'Rare Dankness', org.name
  end
end
