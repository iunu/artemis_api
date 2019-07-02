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
      client.find_all_by_facility(ArtemisApi::Zone.json_type, id)
    end

    def find_zone(zone_id)
      client.find_one_by_facility(ArtemisApi::Zone.json_type, zone_id, id)
    end
  end
end
