require "test_helper"

class BatchDiscardsTest < Minitest::Test
  def setup
    get_client

    stub_request(:get, "http://localhost:3000/api/v3/facilities/2/batch_discards/2")
      .to_return(body: {
        data: {
          id: '2',
          type: 'batch_discards',
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

  def test_finding_a_specific_batch_discard
    batch = ArtemisApi::BatchDiscards.find(2, 2, @client)
    assert_equal 20, batch.quantity
    assert_equal 'disease', batch.reason_type
  end
end
