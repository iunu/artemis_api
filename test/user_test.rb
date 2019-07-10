require "test_helper"

class UserTest < Minitest::Test
  def setup
    options = {app_id: '12345',
               app_secret: '67890',
               base_uri: 'http://localhost:3000'}
    @client = ArtemisApi::Client.new('ya29', 'eyJh', options)

    stub_request(:get, 'http://localhost:3000/api/v3/user')
      .to_return(body: {data: {id: '41', type: 'users', attributes: {id: 41, full_name: 'Jamey Hampton', email: 'jhampton@artemisag.com'}}}.to_json)
  end

  def test_getting_current_user
    user = ArtemisApi::User.get_current(@client)
    assert_equal user.id, 41
    assert_equal user.full_name, 'Jamey Hampton'
    assert_equal user.email, 'jhampton@artemisag.com'
  end
end
