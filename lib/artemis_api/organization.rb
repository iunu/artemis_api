module ArtemisApi
  class Organization < ArtemisApi::Model
    json_type 'organizations'

    def self.find(id, client)
      client.find_one(self.json_type, id)
    end

    def self.find_all(client)
      client.find_all(self.json_type)
    end
  end
end
