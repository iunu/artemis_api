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

    stub_request(:delete, "http://localhost:3000/api/v3/facilities/#{@facility.id}/subscriptions/2")
      .to_return(status: 204, body: {}.to_json)
  end

  def test_finding_all_subscriptions
    subscriptions = ArtemisApi::Subscription.find_all(facility_id: @facility.id, client: @client)
    assert_equal 2, subscriptions.count
  end

  def test_finding_all_subscriptions_through_facility
    subscriptions = @facility.subscriptions
    assert_equal 2, subscriptions.count
  end

  def test_finding_a_specific_subscription
    subscription = ArtemisApi::Subscription.find(id: 2, facility_id: @facility.id, client: @client)
    assert_equal 'batches', subscription.subject
    assert_equal 'http://localhost:8080/another/fake/url', subscription.destination
  end

  def test_finding_a_specific_subscription_through_facility
    subscription = @facility.subscription(2)
    assert_equal 'batches', subscription.subject
    assert_equal 'http://localhost:8080/another/fake/url', subscription.destination
  end

  def test_creating_a_new_subscription
    subscription = ArtemisApi::Subscription.create(facility_id: @facility.id,
                                                   subject: 'completions',
                                                   destination: 'http://localhost:8080/a/fake/url',
                                                   client: @client)
    assert_equal 'completions', subscription.subject
    assert_equal 'http://localhost:8080/a/fake/url', subscription.destination
    assert_equal 1, @client.objects['subscriptions'].count
  end

  def test_deleting_a_subscription
    # find the subscription first to ensure it's in the objects hash
    ArtemisApi::Subscription.find(id: 2, facility_id: @facility.id, client: @client)
    assert_equal 1, @client.objects['subscriptions'].count

    # then delete it and ensure it has been removed from the objects hash
    ArtemisApi::Subscription.delete(id: 2, facility_id: @facility.id, client: @client)
    assert_equal 0, @client.objects['subscriptions'].count
  end
end
