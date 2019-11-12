require "test_helper"

class BatchTest < Minitest::Test
  def setup
    get_client
    get_facility

    stub_request(:get, "http://localhost:3000/api/v3/facilities/#{@facility.id}/batches")
      .to_return(body: {data: [{id: '1', type: 'batches', attributes: {id: 1, arbitrary_id: 'Jun16-Gem-Let'}}, {id: '2', type: 'batches', attributes: {id: 2, name: 'Jun19-Bok-Cho'}}]}.to_json)

    stub_request(:get, "http://localhost:3000/api/v3/facilities/#{@facility.id}/batches/2")
      .to_return(body: {data: {id: '2', type: 'batches', attributes: {id: 2, arbitrary_id: 'Jun19-Bok-Cho'}}}.to_json)

    stub_request(:get, "http://localhost:3000/api/v3/facilities/#{@facility.id}/batches/2?include=zone")
      .to_return(body: {data:
                         {id: '2',
                          type: 'batches',
                          attributes: {id: 2, arbitrary_id: 'Jun19-Bok-Cho'},
                          relationships: {zone: {data: {id: 1, type: 'zones'}}}
                        },
                        included: [{id: '1', type: 'zones', attributes: {id: 1, name: 'Germination'}}]}.to_json)

    stub_request(:get, "http://localhost:3000/api/v3/facilities/#{@facility.id}/batches?filter[search]=oct")
      .to_return(body: {data: [{id: '1', type: 'batches', attributes: {id: 1, arbitrary_id: 'Oct16-Gem-Let'}}, {id: '2', type: 'batches', attributes: {id: 2, name: 'Oct19-Bok-Cho'}}]}.to_json)

    stub_request(:get, "http://localhost:3000/api/v3/facilities/#{@facility.id}/batches?filter[ids][]=2&filter[ids][]=3")
      .to_return(body: {data: [{id: '2', type: 'batches', attributes: {id: 2, name: 'Oct19-Bok-Cho'}}]}.to_json)

    stub_request(:get, "http://localhost:3000/api/v3/facilities/#{@facility.id}/batches?page[limit]=1&page[offset]=4")
      .to_return(body: {data: [{id: '2', type: 'batches', attributes: {id: 2, name: 'Oct19-Bok-Cho'}}]}.to_json)
  end

  def test_finding_all_batches
    batches = ArtemisApi::Batch.find_all(facility_id: @facility.id, client: @client)
    assert_equal 2, batches.count
  end

  def test_finding_all_batches_through_facility
    batches = @facility.batches
    assert_equal 2, batches.count
  end

  def test_finding_a_specific_batch
    batch = ArtemisApi::Batch.find(id: 2, facility_id: @facility.id, client: @client)
    assert_equal 'Jun19-Bok-Cho', batch.arbitrary_id
  end

  def test_finding_a_specific_batch_through_facility
    batch = @facility.batch(2)
    assert_equal 'Jun19-Bok-Cho', batch.arbitrary_id
  end

  def test_finding_a_batch_with_zone_included
    batch = ArtemisApi::Batch.find(id: 2, facility_id: @facility.id, client: @client, include: "zone")
    assert_equal 'Jun19-Bok-Cho', batch.arbitrary_id
    assert_equal @client.objects['zones'].count, 1

    zone = ArtemisApi::Zone.find(id: 1, facility_id: @facility.id, client: @client)
    assert_equal zone.name, 'Germination'
  end

  def test_related_to_one_zone
    batch = ArtemisApi::Batch.find(id: 2, facility_id: @facility.id, client: @client, include: "zone")
    zone = batch.zone
    assert_equal zone.name, 'Germination'
  end

  def test_filtering_by_search_term
    batches = ArtemisApi::Batch.find_all(facility_id: @facility.id, client: @client, filters: {search: "oct"})
    assert_equal 2, batches.count
  end

  def test_filtering_by_ids
    batches = ArtemisApi::Batch.find_all(facility_id: @facility.id, client: @client, filters: {ids: [2, 3]})
    assert_equal 1, batches.count
  end

  def test_filtering_by_date_window
    ending = Time.now + 2.day
    beginning = ending - 15.days
    date_window = [beginning, ending].join(',')

    # TODO: Figure out how the filtering syntax goes.
    stub_request(:get, "http://localhost:3000/api/v3/facilities/#{@facility.id}/batches?filter[date_type]=seeded_at&filter[date_window]=")
      .to_return(body: {data: [{id: '1', type: 'batches', attributes: {id: 1, arbitrary_id: 'Oct16-Gem-Let'}}, {id: '2', type: 'batches', attributes: {id: 2, name: 'Oct19-Bok-Cho'}}]}.to_json)

    batches = ArtemisApi::Batch.find_all(facility_id: @facility.id, client: @client, filters: {date_type: "seeded_at", date_window: date_window})
    assert_equal 2, batches.count
  end

  def test_pagination
    batches = ArtemisApi::Batch.find_all(facility_id: @facility.id, client: @client, page: {limit: 1, offset: 4})
    assert_equal 1, batches.count
  end
end
