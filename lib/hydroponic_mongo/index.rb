module HydroponicMongo
  class Index
    attr_reader :database, :v, :key, :name, :collection

    def initialize(database, key, name, collection)
      @database = database
      @v = 2
      @key = key
      @name = name
      @collection = collection
    end

    def ns
      "#{database}.#{collection}"
    end

    def id_to_bson
      BSON::Document.new.tap do |doc|
        doc.store 'v', v
        doc.store 'key', key
        doc.store 'name', name
        doc.store 'ns', ns
      end
    end
  end
end
