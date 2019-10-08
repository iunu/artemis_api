module ArtemisApi
  class Facility < ArtemisApi::Model
    json_type 'facilities'

    def self.find(id:, client:, include: nil, force: false)
      client.find_one(self.json_type, id, include: include, force: force)
    end

    def self.find_all(client:, include: nil)
      client.find_all(self.json_type, include: include)
    end

    def zones
      ArtemisApi::Zone.find_all(facility_id: id, client: client)
    end

    def zone(zone_id)
      ArtemisApi::Zone.find(id: zone_id, facility_id: id, client: client)
    end

    def batches
      ArtemisApi::Batch.find_all(facility_id: id, client: client)
    end

    def batch(batch_id)
      ArtemisApi::Batch.find(id: batch_id, facility_id: id, client: client)
    end

    def users
      ArtemisApi::User.find_all(facility_id: id, client: client)
    end

    def user(user_id)
      ArtemisApi::User.find(id: user_id, facility_id: id, client: client)
    end

    def seeding_units
      ArtemisApi::SeedingUnit.find_all(facility_id: id, client: client)
    end

    def seeding_unit(unit_id)
      ArtemisApi::SeedingUnit.find(id: unit_id, facility_id: id, client: client)
    end

    def harvest_units
      ArtemisApi::HarvestUnit.find_all(facility_id: id, client: client)
    end

    def harvest_unit(unit_id)
      ArtemisApi::HarvestUnit.find(id: unit_id, facility_id: id, client: client)
    end
  end
end
