module ArtemisApi
  class Facility < ArtemisApi::Model
    json_type 'facilities'

    def self.find(id:, client:, include: nil, force: false)
      client.find_one(self.json_type, id, include: include, force: force)
    end

    def self.find_all(client:, include: nil)
      client.find_all(self.json_type, include: include)
    end

    def zones(include: nil)
      ArtemisApi::Zone.find_all(facility_id: id, client: client, include: include)
    end

    def zone(zone_id, include: nil)
      ArtemisApi::Zone.find(id: zone_id, facility_id: id, client: client, include: include)
    end

    def batches(include: nil)
      ArtemisApi::Batch.find_all(facility_id: id, client: client, include: include)
    end

    def batch(batch_id, include: nil)
      ArtemisApi::Batch.find(id: batch_id, facility_id: id, client: client, include: include)
    end

    def users(include: nil)
      ArtemisApi::User.find_all(facility_id: id, client: client, include: include)
    end

    def user(user_id, include: nil)
      ArtemisApi::User.find(id: user_id, facility_id: id, client: client, include: include)
    end

    def seeding_units(include: nil)
      ArtemisApi::SeedingUnit.find_all(facility_id: id, client: client, include: include)
    end

    def seeding_unit(unit_id, include: nil)
      ArtemisApi::SeedingUnit.find(id: unit_id, facility_id: id, client: client, include: include)
    end

    def harvest_units(include: nil)
      ArtemisApi::HarvestUnit.find_all(facility_id: id, client: client, include: include)
    end

    def harvest_unit(unit_id, include: nil)
      ArtemisApi::HarvestUnit.find(id: unit_id, facility_id: id, client: client, include: include)
    end

    def subscriptions
      ArtemisApi::Subscription.find_all(facility_id: id, client: client)
    end

    def subscription(subscription_id)
      ArtemisApi::Subscription.find(id: subscription_id, facility_id: id, client: client)
    end

    def create_subscription(subject:, destination:)
      ArtemisApi::Subscription.create(facility_id: id, subject: subject, destination: destination, client: client)
    end
  end
end
