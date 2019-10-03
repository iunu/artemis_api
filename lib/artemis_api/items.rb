module ArtemisApi
  class Items < ArtemisApi::Model
    json_type 'items'

    def self.find_all(facility_id, batch_id, client, seeding_unit_id: nil, include: nil)
      client.find_all(self.json_type, facility_id: facility_id, batch_id: batch_id, seeding_unit_id: seeding_unit_id, include: include)
    end
  end
end
