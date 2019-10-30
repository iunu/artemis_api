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

  def test_creating_a_client_instance_with_auth_code
    stub_request(:post, 'http://localhost:3000/oauth/token')
      .with(body: {"client_id"=>"12345",
                    "client_secret"=>"67890",
                    "code"=>"aJ7xsj7",
                    "grant_type"=>"authorization_code",
                    "redirect_uri"=>"urn:ietf:wg:oauth:2.0:oob"})
      .to_return(status: 200, body: {access_token: 'ya29', refresh_token: 'eyJh', expires_in: 7200, token_type: 'Bearer', created_at: Time.now.to_i}.to_json, headers: { 'Content-Type'=> 'application/json;charset=UTF-8'})

    options = {app_id: '12345',
               app_secret: '67890',
               base_uri: 'http://localhost:3000'}
    @client = ArtemisApi::Client.new(auth_code: 'aJ7xsj7', options: options)

    assert_equal '12345', @client.oauth_client.id
    assert_equal 'ya29', @client.oauth_token.token
    assert_equal false, @client.oauth_token.expired?
  end

  def test_creating_an_invalid_client_instance
    assert_raises(ArgumentError) { ArtemisApi::Client.new(access_token: 'ya29') }
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
