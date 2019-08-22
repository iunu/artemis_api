require "test_helper"

class ClientTest < Minitest::Test
  def test_creating_a_client_instance
    get_client

    assert_equal '12345', @client.oauth_client.id
    assert_equal 'ya29', @client.oauth_token.token
    assert_equal @todays_date, @client.oauth_token.params[:created_at]
    assert_equal 7200, @client.oauth_token.expires_in
    assert_equal false, @client.oauth_token.expired?
  end
end
