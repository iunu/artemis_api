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
  end
end
