# frozen_string_literal: true

module HydroponicMongo
  class Query
    module Operator
      def self.to_proc(query, op, value)
        case op
        when '$eq'
          -> id, doc, name {
            query.resolve_field_name(doc, name)[1] == value
          }
        when '$gt'
          -> id, doc, name {
            query.resolve_field_name(doc, name)[1] > value
          }
        when '$gte'
          -> doc, name {
            id, query.resolve_field_name(doc, name)[1] >= value
          }
        when '$in'
          -> id, doc, name {
            exists, field = query.resolve_field_name(doc, name)
            case field
            when Array
              (field & value).present?
            else
              value.include?(field)
            end
          }
        when '$lt'
          -> id, doc, name {
            query.resolve_field_name(doc, name)[1] < value
          }
        when '$lte'
          -> id, doc, name {
            query.resolve_field_name(doc, name)[1] <= value
          }
        when '$ne'
          -> id, doc, name {
            query.resolve_field_name(doc, name) != value
          }
        when '$nin'
          -> id, doc, name {
            exists, field = query.resolve_field_name(doc, name)
            !exists || case field
            when Array
              (field & value).empty?
            else
              !value.include?(field)
            end
          }
        when '$exists'
          -> id, doc, name {
            query.resolve_field_name(doc, name)[0]
          }
        end
      end
    end
  end
end
