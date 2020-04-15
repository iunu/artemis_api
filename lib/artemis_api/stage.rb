module ArtemisApi
  class Stage < ArtemisApi::Model
    json_type 'stages'
    related_to_many :sub_stages
    related_to_many :zones

    def self.find(id, facility_id, client, include: 'sub_stages,zones', force: false)
      client.find_one(self.json_type, id, facility_id: facility_id, include: include, force: force)
    end

    def self.find_all(facility_id, client, include: 'sub_stages,zones')
      client.find_all(self.json_type, facility_id: facility_id, include: include)
    end
  end
end
