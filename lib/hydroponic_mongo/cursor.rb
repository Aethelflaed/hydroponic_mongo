module HydroponicMongo
  class Cursor
    def initialize(ns, data)
      @ns = ns
      @data = data
    end

    def bson_type
      BSON::Document::BSON_TYPE
    end

    def to_bson
      BSON::Document.new.tap do |doc|
        cursor = BSON::Document.new.tap do |cursor|
          cursor.store('id', 0)
          cursor.store('ns', @ns)
          cursor.store('firstBatch', @data)
        end
        doc.store('cursor', cursor)
        doc.store('ok', 1.0)
      end
    end
  end
end
