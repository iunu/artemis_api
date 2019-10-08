require "test_helper"

class ItemsTest < Minitest::Test
  def setup
    get_client

    stub_request(:get, 'http://localhost:3000/api/v3/facilities/2')
      .to_return(body: {data: {id: '2', type: 'facilities', attributes: {id: 2, name: 'Rare Dankness'}}}.to_json)
    @facility = ArtemisApi::Facility.find(2, @client)

    stub_request(:get, "http://localhost:3000/api/v3/facilities/#{@facility.id}/batches/2")
      .to_return(body: {data: {id: '2', type: 'batches', attributes: {id: 2, arbitrary_id: 'Jun19-Bok-Cho'}, relationships: {seeding_unit: {data: {id: '3479', type: 'seeding_units'}}}}}.to_json)
    @batch = ArtemisApi::Batch.find(2, @facility.id, @client)

    stub_request(:get, "http://localhost:3000/api/v3/facilities/#{@facility.id}/batches/2/items")
      .to_return(body: {data: [{id: '326515', type: 'items', attributes: {id: 326515, status: 'active'}, relationships: {barcode: {data: {id: '1A4FF0200000022000000207', type: 'barcodes'}}}}]}.to_json)

    stub_request(:get, "http://localhost:3000/api/v3/facilities/#{@facility.id}/batches/2/items?filter[seeding_unit_id]=100")
      .to_return(body: {data: [{id: '326515', type: 'items', attributes: {id: 326515, status: 'active'}, relationships: {barcode: {data: {id: '1A4FF0200000022000000207', type: 'barcodes'}}, seeding_unit: {data: {id: '100', type: 'seeding_units'}}}}]}.to_json)
  end

  def test_finding_all_items_of_facility_and_batch
    items = ArtemisApi::Items.find_all(@facility.id, @batch.id, @client)
    assert_equal 1, items.count
    assert_equal 326_515, items.first.id
    assert_equal '1A4FF0200000022000000207', items.first.relationships.dig('barcode', 'data', 'id')
  end

  def test_finding_all_items_with_seeding_unit
    seeding_unit_id = 100
    items = ArtemisApi::Items.find_all(@facility.id, @batch.id, @client, filters: {seeding_unit_id: seeding_unit_id})
    assert_equal 1, items.count
    assert_equal seeding_unit_id.to_s, items.first.relationships.dig('seeding_unit', 'data', 'id')
  end
end
