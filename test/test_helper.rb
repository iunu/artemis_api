$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "artemis_api"

require "minitest/autorun"
require "webmock/minitest"

def get_client
  options = {app_id: '12345',
             app_secret: '67890',
             base_uri: 'http://localhost:3000'}
  @todays_date = DateTime.now
  @client = ArtemisApi::Client.new('ya29', 'eyJh', 7200, @todays_date, options)
end
