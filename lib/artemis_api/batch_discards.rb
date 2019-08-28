module ArtemisApi
  class BatchDiscards < ArtemisApi::Model
    json_type 'batch_discards'

    def self.find(id, facility_id, client, include: nil, force: false)
      client.find_one(self.json_type, id, facility_id: facility_id, include: include, force: force)
    end
  end
end
