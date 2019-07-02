module ArtemisApi
  class Zone < ArtemisApi::Model
    json_type 'zones'

    def self.find(id, facility_id, client)
      client.find_one_by_facility(self.json_type, id, facility_id)
    end

    def self.find_all(facility_id, client)
      client.find_all_by_facility(self.json_type, facility_id)
    end
  end
end
