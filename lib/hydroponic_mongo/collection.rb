# frozen_string_literal: true

require 'hydroponic_mongo/index'
require 'hydroponic_mongo/transducer'
require 'hydroponic_mongo/criteria'

module HydroponicMongo
  class Collection
    attr_reader :database, :name, :options, :info, :documents, :indices

    def initialize(database, name)
      @database = database
      @name = name
      @options = {}
      @info = {'readOnly' => false}
      @documents = {}
      @indices = {}
      @indices[Index::ID_INDEX_NAME] = Index.new(self, Index::ID_INDEX_NAME, {'_id' => 1})
    end

    def idIndex
      indices[Index::ID_INDEX_NAME]
    end

    def bson_type
      BSON::Document::BSON_TYPE
    end

    def to_bson
      BSON::Document.new.tap do |doc|
        doc.store 'name', name
        doc.store 'type', 'collection'
        doc.store 'options', options
        doc.store 'info', info
        doc.store 'idIndex', idIndex.to_bson
      end
    end

    def insert(documents)
      documents.map do |document|
        insert_one(document)
      end.uniq.count
    end

    def find(criteria = {}, options = {})
      criteria = Criteria.new(criteria)

      if criteria.empty?
        documents.values
      elsif criteria.id?
        [documents[criteria.id]].compact
      else
        Transducer.eval(documents.values) do
          criteria.each do |criterion|
            filter &criterion
          end
          reduce :push
        end
      end
    end

    private
    def insert_one(document)
      if !document.has_key?('_id')
        document.store '_id', BSON::ObjectId.new
      end
      documents[document['_id']] = document

      document['_id']
    end
  end
end
