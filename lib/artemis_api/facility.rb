module ArtemisApi
  class Facility < ArtemisApi::Model
    json_type 'facilities'

    def self.find(id, client, include: nil)
      client.find_one(self.json_type, id, include: include)
    end

    def self.find_all(client, include: nil)
      client.find_all(self.json_type, include: include)
    end

    def zones
      client.find_all(ArtemisApi::Zone.json_type, facility_id: id)
    end

    def find_zone(zone_id)
      client.find_one(ArtemisApi::Zone.json_type, zone_id, facility_id: id)
    end

    def batches
      client.find_all(ArtemisApi::Batch.json_type, facility_id: id)
    end

    def find_batch(batch_id)
      client.find_one(ArtemisApi::Batch.json_type, batch_id, facility_id: id)
    end
  end
end
