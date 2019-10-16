require "test_helper"

class UserTest < Minitest::Test
  def setup
    get_client
    get_facility

    stub_request(:get, "http://localhost:3000/api/v3/user")
      .to_return(body: {data: {id: '41', type: 'users', attributes: {id: 41, full_name: 'Jamey Hampton', email: 'jhampton@artemisag.com'}}}.to_json)

    stub_request(:get, "http://localhost:3000/api/v3/facilities/#{@facility.id}/users")
      .to_return(body: {data: [{id: '41', type: 'users', attributes: {id: 41, full_name: 'Jamey Hampton', email: 'jhampton@artemisag.com'}}, {id: '42', type: 'users', attributes: {id: 42, full_name: 'Developer', email: 'developer@artemisag.com'}}]}.to_json)

    stub_request(:get, "http://localhost:3000/api/v3/facilities/#{@facility.id}/users/42")
      .to_return(body: {data: {id: '42', type: 'users', attributes: {id: 42, full_name: 'Developer', email: 'developer@artemisag.com'}}}.to_json)
  end

  def test_getting_current_user
    user = ArtemisApi::User.get_current(client: @client)
    assert_equal user.id, 41
    assert_equal user.full_name, 'Jamey Hampton'
    assert_equal user.email, 'jhampton@artemisag.com'
  end

  def test_finding_all_users
    users = ArtemisApi::User.find_all(facility_id: @facility.id, client: @client)
    assert_equal 2, users.count
    assert_equal 2, @client.objects['users'].count
  end

  def test_finding_all_users_through_facility
    users = @facility.users
    assert_equal 2, users.count
  end

  def test_finding_a_specific_user
    user = ArtemisApi::User.find(id: 42, facility_id: @facility.id, client: @client)
    assert_equal user.full_name, 'Developer'
    assert_equal user.email, 'developer@artemisag.com'
  end

  def test_finding_a_specific_user_through_facility
    user = @facility.user(42)
    assert_equal user.full_name, 'Developer'
    assert_equal user.email, 'developer@artemisag.com'
  end

  def test_finding_a_user_with_included_organizations
    stub_request(:get, 'http://localhost:3000/api/v3/facilities/2/users/42?include=organizations')
      .to_return(body: {data:
                         {id: '42',
                          type: 'users',
                          attributes: {id: 42, full_name: 'Developer', email: 'developer@artemisag.com'}},
                        included: [{id: '1', type: 'organizations', attributes: {id: 1, name: 'Vegetable Sky'}}]}.to_json)

    user = ArtemisApi::User.find(id: 42, facility_id: @facility.id, client: @client, include: "organizations")
    assert_equal user.full_name, 'Developer'
    assert_equal user.email, 'developer@artemisag.com'
    assert_equal @client.objects['organizations'].count, 1

    # Since the organization has already been included and stored in the client objects array,
    # this call doesn't actually hit the API and consdoesn't need to be stubbed.
    organization = ArtemisApi::Organization.find(id: 1, client: @client)
    assert_equal organization.name, 'Vegetable Sky'
  end
end
