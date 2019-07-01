module ArtemisApi
  class Facility < ArtemisApi::Model
    json_type 'facilities'

    def self.find(id, client)
      self.json_type
      client.find_one('facilities', id)
    end

    def self.find_all(client)
      self.json_type
      client.find_all('facilities')
    end
  end
end
