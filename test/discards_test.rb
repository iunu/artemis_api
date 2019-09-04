require "test_helper"

class DiscardsTest < Minitest::Test
  def setup
    get_client
    get_facility

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
            batch: {
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

    stub_request(:get, "http://localhost:3000/api/v3/facilities/2/discards/2?include=batch")
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
            batch: {
              data: {
                id: '156',
                type: 'batches'
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

      stub_request(:get, "http://localhost:3000/api/v3/facilities/#{@facility.id}/discards")
        .to_return(body: {data: [{id: '1', type: 'discards', attributes: {id: 1, reason_type: 'disease', quantity: 20}}, {id: '2', type: 'discards', attributes: {id: 2, reason_type: 'pests', quantity: 5}}]}.to_json)
  end

  def test_finding_a_specific_discard
    discard = ArtemisApi::Discard.find(2, @facility.id, @client)
    assert_equal 20, discard.quantity
    assert_equal 'disease', discard.reason_type
    assert_equal false, discard.relationships['batch']['meta']['included']
    assert discard.relationships['batch']['data'].nil?
  end

  def test_finding_a_specific_discard_with_batch_included
    discard = ArtemisApi::Discard.find(2, @facility.id, @client, include: 'batch')
    assert_equal 20, discard.quantity
    assert_equal 'disease', discard.reason_type
    assert_equal '156', discard.relationships['batch']['data']['id']
    assert discard.relationships['batch']['meta'].nil?
  end

  def test_finding_all_discards
    discards = ArtemisApi::Discard.find_all(@facility.id, @client)
    assert_equal 2, discards.count
  end
end
