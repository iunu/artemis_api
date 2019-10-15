require "test_helper"

class SubscriptionTest < Minitest::Test
  def setup
    get_client
    get_facility

    stub_request(:get, "http://localhost:3000/api/v3/facilities/#{@facility.id}/subscriptions")
      .to_return(body: {data: [{id: '1', type: 'subscriptions', attributes: {id: 1, subject: 'completions', destination: 'http://localhost:8080/a/fake/url'}}, {id: '2', type: 'subscriptions', attributes: {id: 2, subject: 'batches', destination: 'http://localhost:8080/another/fake/url'}}]}.to_json)

    stub_request(:get, "http://localhost:3000/api/v3/facilities/#{@facility.id}/subscriptions/2")
      .to_return(body: {data: {id: '2', type: 'subscriptions', attributes: {id: 2, subject: 'batches', destination: 'http://localhost:8080/another/fake/url'}}}.to_json)

    stub_request(:post, "http://localhost:3000/api/v3/facilities/#{@facility.id}/subscriptions")
      .with(body: {"subscription"=>{"destination"=>"http://localhost:8080/a/fake/url", "subject"=>"completions"}})
      .to_return(status: 200, body: {data: {id: '3', type: 'subscriptions', attributes: {id: 3, subject: 'completions', destination: 'http://localhost:8080/a/fake/url'}}}.to_json)
  end

  def test_finding_all_subscriptions
    subscriptions = ArtemisApi::Subscription.find_all(@facility.id, @client)
    assert_equal 2, subscriptions.count
  end

  def test_finding_all_subscriptions_through_facility
    subscriptions = @facility.subscriptions
    assert_equal 2, subscriptions.count
  end

  def test_finding_a_specific_subscription
    subscription = ArtemisApi::Subscription.find(2, @facility.id, @client)
    assert_equal 'batches', subscription.subject
    assert_equal 'http://localhost:8080/another/fake/url', subscription.destination
  end

  def test_finding_a_specific_subscription_through_facility
    subscription = @facility.find_subscription(2)
    assert_equal 'batches', subscription.subject
    assert_equal 'http://localhost:8080/another/fake/url', subscription.destination
  end

  def test_creating_a_new_subscription
    subscription = ArtemisApi::Subscription.create(@facility.id, 'completions', 'http://localhost:8080/a/fake/url', @client)
    assert_equal 'completions', subscription.subject
    assert_equal 'http://localhost:8080/a/fake/url', subscription.destination
    assert_equal 1, @client.objects['subscriptions'].count
  end
end
