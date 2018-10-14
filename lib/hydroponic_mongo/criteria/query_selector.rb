# frozen_string_literal: true

module HydroponicMongo
  module Criterion
    module QuerySelector
      def self.to_proc(op, value)
        case op
        when '$eq'
          -> doc, name {
            doc[name] == value
          }
        when '$gt'
          -> doc, name {
            doc[name]> value
          }
        when '$gte'
          -> doc, name {
            doc[name] >= value
          }
        when '$in'
          -> doc, name {
            case (field = doc[name])
            when Array
              (field & value).present?
            else
              value.include?(field)
            end
          }
        when '$lt'
          -> doc, name {
            doc[name] < value
          }
        when '$lte'
          -> doc, name {
            doc[name] <= value
          }
        when '$ne'
          -> doc, name {
            doc[name] != value
          }
        when '$nin'
          -> doc, name {
            !doc.key?(name) || case (field = doc[name])
            when Array
              (field & value).empty?
            else
              !value.include?(field)
            end
          }
        when '$exists'
          -> doc, name {
            doc.key?(name)
          }
        end
      end
    end
  end
end
