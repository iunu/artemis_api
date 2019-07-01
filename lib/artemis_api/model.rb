module ArtemisApi
  class Model
    attr_reader :client, :id, :attributes, :relationships

    def self.related_to_one(name)
      self.send(:define_method, name.to_sym) do
        @client.find_one(self.relationships[name].type, self.relationships[name].id)
      end
    end

    def self.related_to_many(name)
      self.send(:define_method, name.to_sym) do
        @client.find_all(self.relationships[name].type)
      end
    end

    def self.json_type(type = nil)
      if type
        @json_type = type
        @@registered_classes ||= {}
        @@registered_classes[type] = self
      end
      @json_type
    end

    def self.instance_for(type, data, client)
      # TODO: Issue: @@registered_classes is empty unless you explicitly call json_type on the models first
      @@registered_classes[type]&.new(client, data)
    end

    def method_missing(name)
      attributes[name.to_s]
    end

    def initialize(client, data)
      @client = client
      @id = data['id'].to_i
      @attributes = data['attributes']
      @relationships = data['relationships']
    end
  end
end
