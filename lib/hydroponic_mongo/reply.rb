# frozen_string_literal: true

module HydroponicMongo
  class Reply
    def bson_type
      BSON::Document::BSON_TYPE
    end

    def to_bson
      BSON::Document.new
    end

    def new_document
      BSON::Document.new.tap{|d| yield d}
    end
  end
end

require 'hydroponic_mongo/reply/count'
require 'hydroponic_mongo/reply/cursor'
