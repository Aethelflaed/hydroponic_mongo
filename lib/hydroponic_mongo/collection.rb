# frozen_string_literal: true

require 'transducer'
require 'hydroponic_mongo/index'
require 'hydroponic_mongo/query'
require 'hydroponic_mongo/update'

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

    def find(query = nil, options = {})
      query = Query.new(query || {}, documents, options)

      result = query.documents

      # TODO:
      # Handle options:
      # - options['projection']

      return result.deep_dup
    end

    def update(query, update, options = {})
      query_options = {}
      if !options['multi']
        query_options['limit'] = 1
      else
        if update.keys.first[0] != '$'
          raise WriteError.new(9, "multi update only works with $ operators")
        end
      end

      query = Query.new(query, documents, query_options)

      documents = query.documents
      count = documents.size
      modified = 0
      upserted = []
      options['position'] = query.position

      if documents.empty?
        if options['upsert']
          upserted.push upsert(update, options)['_id']
        end
      else
        documents.each do |document|
          if update_one(document, update, options)
            modified += 1
          end
        end
      end

      return [count, modified, upserted]
    end

    def insert_one(document)
      id = (document['_id'] ||= BSON::ObjectId.new)
      documents[id] = document

      return id
    end

    def upsert(update, options = {})
      doc = BSON::Document.new
      update_one(doc, update, options.merge('upserting' => true))

      insert_one(doc)

      return doc
    end

    def delete(query, options = {})
      query = Query.new(query, documents, options)

      documents = query.documents
      count = documents.size

      documents.each do |doc|
        self.documents.delete(doc['_id'])
      end

      return count
    end

    def update_one(document, update, options = {})
      original_id = document['_id']

      rval =
        if update.keys.first[0] == '$'
          # using update operators
          Update.apply(document, update, options)
        else
          # replace document

          # make sure we don't override the _id
          if !options['upserting']
            update.delete('_id')
          end

          # Delete all fields
          document.delete_if{|k, v| k != '_id'}

          # Set updates fields
          document.merge!(update)

          true
        end

      if original_id != document['_id']
        self.documents.delete(original_id)
        self.documents[document['_id']] = document
      end

      return rval
    end

    def delete_one(id)
      documents.delete(id)
    end
  end
end
