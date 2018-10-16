# frozen_string_literal: true

module HydroponicMongo
  class Reply::Cursor < Reply
    def initialize(ns, data)
      @ns = ns
      @data = data
    end

    def data_to_bson
      @data.map do |value|
        case value
        when BSON::Document
          value
        else
          value.to_bson
        end
      end
    end

    def to_bson
      new_document do |doc|
        cursor = new_document do |c|
          c.store('id', 0)
          c.store('ns', @ns)
          c.store('firstBatch', data_to_bson)
        end
        doc.store('cursor', cursor)
        doc.store('ok', 1.0)
      end
    end
  end
end
