require "test_helper"

class ClientTest < Minitest::Test
  def test_creating_a_client_instance
    options = {app_id: '12345',
               app_secret: '67890',
               base_uri: 'http://localhost:3000'}

    tomorrows_date = 1.days.from_now.to_i
    client = ArtemisApi::Client.new('ya29', 'eyJh', tomorrows_date, options)

    assert_equal '12345', client.oauth_client.id
    assert_equal 'ya29', client.oauth_token.token
    assert_equal tomorrows_date, client.oauth_token.expires_at
    assert_equal false, client.oauth_token.expired?
  end
end
