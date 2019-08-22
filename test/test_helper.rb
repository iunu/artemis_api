$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "artemis_api"

require "minitest/autorun"
require "webmock/minitest"
require "active_support"
require "active_support/core_ext/numeric"

def get_client
  options = {app_id: '12345',
             app_secret: '67890',
             base_uri: 'http://localhost:3000'}
  @expires_at = 1.days.from_now
  @client = ArtemisApi::Client.new('ya29', 'eyJh', @expires_at, options)
end
