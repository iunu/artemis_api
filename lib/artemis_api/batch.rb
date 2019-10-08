module ArtemisApi
  class Batch < ArtemisApi::Model
    json_type 'batches'

    def self.find(id:, client:, facility_id:, include: nil, force: false)
      client.find_one(self.json_type, id, facility_id: facility_id, include: include, force: force)
    end

    def self.find_all(client:, facility_id:, include: nil, filters: nil)
      client.find_all(self.json_type, facility_id: facility_id, include: include, filters: filters)
    end

    def completions
      ArtemisApi::Completion.find_all(facility_id, client, filters: {crop_batch_ids: [id]})
    end

    def discards
      ArtemisApi::Discard.find_all(facility_id, client, filters: {crop_batch_ids: [id]})
    end

    def harvests
      ArtemisApi::Harvest.find_all(facility_id, client, filters: {crop_batch_ids: [id]})
    end

    def items(seeding_unit_id: nil)
      ArtemisApi::Item.find_all(facility_id, id, client, filters: {seeding_unit_id: seeding_unit_id})
    end
  end
end
