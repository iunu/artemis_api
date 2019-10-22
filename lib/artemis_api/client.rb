module ArtemisApi
  class Client
    require 'oauth2'
    attr_reader :options, :objects, :access_token, :refresh_token, :oauth_client,
                :oauth_token, :expires_at

    def initialize(access_token:, refresh_token:, expires_at:, options: {})
      options[:app_id] ||= ENV['ARTEMIS_OAUTH_APP_ID']
      options[:app_secret] ||= ENV['ARTEMIS_OAUTH_APP_SECRET']
      options[:base_uri] ||= ENV['ARTEMIS_BASE_URI']
      @options = options
      @access_token = access_token
      @refresh_token = refresh_token
      @expires_at = expires_at

      @oauth_client = OAuth2::Client.new(@options[:app_id], @options[:app_secret], site: @options[:base_uri])
      @oauth_token = OAuth2::AccessToken.from_hash(
                      oauth_client,
                      {access_token: @access_token,
                       refresh_token: @refresh_token,
                       expires_at: @expires_at})
      @objects = {}
    end

    def find_one(type, id, facility_id: nil, include: nil, force: false)
      obj = get_record(type, id)
      if !obj || force
        refresh if @oauth_token.expired?

        url = if facility_id
                "#{@options[:base_uri]}/api/v3/facilities/#{facility_id}/#{type}/#{id}"
              else
                "#{@options[:base_uri]}/api/v3/#{type}/#{id}"
              end
        url = "#{url}?include=#{include}" if include

        response = @oauth_token.get(url)
        obj = process_response(response, type) if response.status == 200
      end
      obj
    end

    def find_all(type, facility_id: nil, batch_id: nil, include: nil, filters: nil)
      records = []
      refresh if @oauth_token.expired?

      url = if facility_id && batch_id
              "#{@options[:base_uri]}/api/v3/facilities/#{facility_id}/batches/#{batch_id}/#{type}"
            elsif facility_id && batch_id.nil?
              "#{@options[:base_uri]}/api/v3/facilities/#{facility_id}/#{type}"
            else
              "#{@options[:base_uri]}/api/v3/#{type}"
            end
      url = "#{url}?include=#{include}" if include
      url = "#{url}?#{format_filters(filters)}" if filters

      response = @oauth_token.get(url)
      if response.status == 200
        records = process_array(response, type, records)
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

    def facilities(include: nil)
      find_all('facilities', include: include)
    end

    def facility(id, include: nil, force: false)
      find_one('facilities', id, include: include, force: force)
    end

    def organizations(include: nil)
      find_all('organizations', include: include)
    end

    def organization(id, include: nil, force: false)
      find_one('organizations', id, include: include, force: force)
    end

    def current_user(include: nil)
      ArtemisApi::User.get_current(client: self, include: include)
    end

    def process_response(response, type)
      json = JSON.parse(response.body)
      obj = store_record(type, json['data']['id'].to_i, json['data'])
      process_included_objects(json['included']) if json['included']

      obj
    end

    private

    def process_array(response, type, records)
      json = JSON.parse(response.body)
      json['data'].each do |obj|
        record = store_record(type, obj['id'], obj)
        records << record
      end
      process_included_objects(json['included']) if json['included']

      records
    end

    def process_included_objects(included_array)
      included_array.each do |included_obj|
        store_record(included_obj['type'], included_obj['id'], included_obj)
      end
    end

    def format_filters(filter_hash)
      filter_string = ''
      filter_hash.each do |k, v|
        if v.kind_of?(Array)
          v.each do |item|
            filter_string += "filter[#{k}][]=#{item}&"
          end
        else
          filter_string += "filter[#{k}]=#{v}&"
        end
      end
      filter_string
    end
  end
end
