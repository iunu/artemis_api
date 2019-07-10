module ArtemisApi
  class Batch < ArtemisApi::Model
    json_type 'batches'

    def self.find(id, facility_id, client)
      client.find_one(self.json_type, id, facility_id: facility_id)
    end

    def self.find_all(facility_id, client)
      client.find_all(self.json_type, facility_id: facility_id)
    end
  end
end
