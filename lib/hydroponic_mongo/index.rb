# frozen_string_literal: true

module HydroponicMongo
  class Index
    ID_INDEX_NAME = '_id_'

    attr_reader :database, :v, :key, :name, :collection

    def initialize(collection, name, key)
      @database = collection.database
      @v = 2
      @key = key
      @name = name
      @collection = collection
    end

    def ns
      "#{database.name}.#{collection.name}"
    end

    def to_bson
      BSON::Document.new.tap do |doc|
        doc.store 'v', v
        doc.store 'key', key
        doc.store 'name', name
        doc.store 'ns', ns
      end
    end
  end
end
