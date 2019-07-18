module ArtemisApi
  class User < ArtemisApi::Model
    json_type 'users'
    related_to_many :facilities

    def self.get_current(client)
      self.json_type
      client.refresh if client.oauth_token.expired?
      response = client.oauth_token.get("#{client.options[:base_uri]}/api/v3/user")
      if response.status == 200
        json = JSON.parse(response.body)
        obj = client.store_record('users', json['data']['id'], json['data'])
      end
      obj
    end

    def self.find(id, facility_id, client, include: nil)
      client.find_one(self.json_type, id, facility_id: facility_id, include: include)
    end

    def self.find_all(facility_id, client, include: nil)
      client.find_all(self.json_type, facility_id: facility_id, include: include)
    end
  end
end
