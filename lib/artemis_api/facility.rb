module ArtemisApi
  class Facility < ArtemisApi::Model
    json_type 'facilities'

    def self.find(id, client)
      client.find_one(self.json_type, id)
    end

    def self.find_all(client)
      client.find_all(self.json_type)
    end

    def zones
      client.find_all(ArtemisApi::Zone.json_type, facility_id: id)
    end

    def find_zone(zone_id)
      client.find_one(ArtemisApi::Zone.json_type, zone_id, facility_id: id)
    end
  end
end
