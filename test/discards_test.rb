require "test_helper"

class DiscardsTest < Minitest::Test
  def setup
    get_client

    stub_request(:get, "http://localhost:3000/api/v3/facilities/2/discards/2")
      .to_return(body: {
        data: {
          id: '2',
          type: 'discards',
          attributes: {
            id: 2,
            quantity: 20,
            reason_type: 'disease',
            reason_description: ''
          },
          relationships: {
            crop_batch: {
              meta: {
                included: false
              }
            },
            completion: {
              meta: {
                included: false
              }
            }
          }
        }
      }.to_json)

    stub_request(:get, "http://localhost:3000/api/v3/facilities/2/discards/2?include=crop_batch")
      .to_return(body: {
        data: {
          id: '2',
          type: 'discards',
          attributes: {
            id: 2,
            quantity: 20,
            reason_type: 'disease',
            reason_description: ''
          },
          relationships: {
            crop_batch: {
              data: {
                id: '156',
                type: 'crop_batches'
              }
            },
            completion: {
              meta: {
                included: false
              }
            }
          }
        }
      }.to_json)
  end

  def test_finding_a_specific_discard
    batch = ArtemisApi::Discards.find(2, 2, @client)
    assert_equal 20, batch.quantity
    assert_equal 'disease', batch.reason_type
    assert_equal false, batch.relationships['crop_batch']['meta']['included']
    assert batch.relationships['crop_batch']['data'].nil?
  end

  def test_finding_a_specific_discard_with_crop_batch_included
    batch = ArtemisApi::Discards.find(2, 2, @client, include: "crop_batch")
    assert_equal 20, batch.quantity
    assert_equal 'disease', batch.reason_type
    assert_equal '156', batch.relationships['crop_batch']['data']['id']
    assert batch.relationships['crop_batch']['meta'].nil?
  end
end
