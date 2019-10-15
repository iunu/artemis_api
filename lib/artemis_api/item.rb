module ArtemisApi
  class Item < ArtemisApi::Model
    json_type 'items'

    def self.find_all(facility_id:, batch_id:, client:, include: nil, filters: nil)
      client.find_all(self.json_type, facility_id: facility_id, batch_id: batch_id, include: include, filters: filters)
    end
  end
end
