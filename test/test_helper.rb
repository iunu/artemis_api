$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "artemis_api"

require "minitest/autorun"
require "webmock/minitest"
require "active_support"
require "active_support/core_ext/numeric"
require 'active_support/testing/assertions'
include ActiveSupport::Testing::Assertions

def get_client
  options = {app_id: '12345',
             app_secret: '67890',
             base_uri: 'http://localhost:3000'}
  @expires_at = 1.days.from_now
  @client = ArtemisApi::Client.new('ya29', 'eyJh', @expires_at, options)
end

def get_facility
  stub_request(:get, 'http://localhost:3000/api/v3/facilities/2')
    .to_return(body: {data: {id: '2', type: 'facilities', attributes: {id: 2, name: 'Rare Dankness'}}}.to_json)
  @facility = ArtemisApi::Facility.find(2, @client)
end
