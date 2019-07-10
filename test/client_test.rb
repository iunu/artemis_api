require "test_helper"

class ClientTest < Minitest::Test
  def test_creating_a_client_instance
    options = {app_id: '12345',
               app_secret: '67890',
               base_uri: 'http://localhost:3000'}
    client = ArtemisApi::Client.new('ya29', 'eyJh', options)

    assert_equal '12345', client.oauth_client.id
    assert_equal 'ya29', client.oauth_token.token
  end
end
