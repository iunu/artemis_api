module ArtemisApi
  class Client
    require 'oauth2'
    attr_reader :options, :objects, :access_token, :refresh_token, :oauth_client, :oauth_token, :expires_in, :created_at

    def initialize(access_token, refresh_token, expires_in, created_at, options = {})
      options[:app_id] ||= ENV['ARTEMIS_OAUTH_APP_ID']
      options[:app_secret] ||= ENV['ARTEMIS_OAUTH_APP_SECRET']
      options[:base_uri] ||= ENV['ARTEMIS_BASE_URI']
      @options = options
      @access_token = access_token
      @refresh_token = refresh_token
      @expires_in = expires_in
      @created_at = created_at

      @oauth_client = OAuth2::Client.new(@options[:app_id], @options[:app_secret], site: @options[:base_uri])
      @oauth_token = OAuth2::AccessToken.from_hash(
                      oauth_client, 
                      {access_token: @access_token, refresh_token: @refresh_token, created_at: @created_at, expires_in: @expires_in}
                     )

      @objects = {} 
    end

    def find_one(type, id, force = false)
      obj = get_record(type, id)
      if !obj || force
        response = @oauth_token.get("#{@options[:base_uri]}/api/v3/#{type}/#{id}")
        if response.status == 200
          json = JSON.parse(response.body)
          obj = store_record(type, id, json['data'])

          #if json['included']
          #  json['included'].each do |included_obj|
          #    store_record(included_obj['type'], included_obj['id'], included_obj)
          #  end
          #end
        end
      end
      obj
    end

    def find_all(type, params = nil)
      records = []
      response = @oauth_token.get("#{@options[:base_uri]}/api/v3/#{type}")
      if response.status == 200
        json = JSON.parse(response.body)
        json['data'].each do |obj|
          record = store_record(type, obj['id'], obj)
          records << record
        end

        #if json['included']
        #  json['included'].each do |included_obj|
        #    store_record(included_obj['type'], included_obj['id'], included_obj)
        #  end
        #end
      end
      records
    end

    def store_record(type, id, data)
      @objects[type] ||= {}
      @objects[type][id.to_i] = ArtemisApi::Model.instance_for(type, data, self)
    end

    def get_record(type, id)
      @objects[type]&.[](id.to_i)
    end

    def refresh
      @oauth_token = @oauth_token.refresh!
    end
  end
end
