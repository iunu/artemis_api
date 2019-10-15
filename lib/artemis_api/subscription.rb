module ArtemisApi
  class Subscription < ArtemisApi::Model
    json_type 'subscriptions'

    def self.find(id, facility_id, client, include: nil, force: false)
      client.find_one(self.json_type, id, facility_id: facility_id, include: include, force: force)
    end

    def self.find_all(facility_id, client, include: nil, filters: nil)
      client.find_all(self.json_type, facility_id: facility_id, include: include, filters: filters)
    end

    def self.create(facility_id, subject, destination, client)
      client.oauth_token.refresh! if client.oauth_token.expired?

      url = "#{client.options[:base_uri]}/api/v3/facilities/#{facility_id}/subscriptions"
      params = { body: { subscription: { subject: subject, destination: destination } } }

      response = client.oauth_token.post(url, params)

      # TODO: do we need to do something other than this?
      # does the response include the created object? can we store it in the objects hash?
      response.status == 200 ? true : false
    end
  end
end
