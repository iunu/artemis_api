require "test_helper"

class ClientTest < Minitest::Test
  def stub_user
    stub_request(:get, "http://localhost:3000/api/v3/user")
      .to_return(body: {data: {id: '41', type: 'users', attributes: {id: 41, full_name: 'Jamey Hampton', email: 'jhampton@artemisag.com'}}}.to_json)
  end

  def test_creating_a_client_instance
    get_client

    assert_equal '12345', @client.oauth_client.id
    assert_equal 'ya29', @client.oauth_token.token
    assert_equal @expires_at.to_i, @client.oauth_token.expires_at
    assert_equal false, @client.oauth_token.expired?
  end

  def test_current_user
    get_client
    stub_user

    user = @client.current_user
    assert_equal user.class, ArtemisApi::User
  end

  def test_remove_record
    get_client

    type = 'subscriptions'

    # model type added once, removed twice
    @client.store_record(type, 1, 'id' => 1)
    assert_equal 1, @client.get_record(type, 1).id
    @client.remove_record(type, 1)
    assert_nil @client.get_record(type, 1)
    assert_nothing_raised { @client.remove_record(type, 1) }

    # model type not added, attempt to remove one
    undefined_type = 'something'
    assert_nil @client.instance_variable_get(:"@objects")[undefined_type]
    assert_nothing_raised { @client.remove_record(undefined_type, 1) }
  end
end
