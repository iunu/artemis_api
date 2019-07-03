module ArtemisApi
  class Organization < ArtemisApi::Model
    json_type 'organizations'

    def self.find(id, client, include: nil)
      client.find_one(self.json_type, id, include: include)
    end

    def self.find_all(client, include: nil)
      client.find_all(self.json_type, include: include)
    end
  end
end
