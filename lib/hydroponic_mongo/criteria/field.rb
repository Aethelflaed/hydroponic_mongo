# frozen_string_literal: true

module HydroponicMongo
  module Criterion
    module Field
      def self.to_proc(name, value)
        case value
        when Hash
          -> (doc) {
            value.all? do |op, val|
              QuerySelector.to_proc(op, val).call(doc, name)
            end
          }
        else
          -> (doc) {
            doc[name] == value
          }
        end
      end
    end
  end
end
