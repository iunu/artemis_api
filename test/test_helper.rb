$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "artemis_api"

require "minitest/autorun"
require "webmock/minitest"
require "active_support"
require "active_support/core_ext/numeric"
