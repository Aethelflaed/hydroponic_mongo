# frozen_string_literal: true

module HydroponicMongo
  module Criterion
    module Or
      def self.to_proc(values)
        -> (doc) {
          values.any? do |value|
            Criteria.factory(*value).call(doc)
          end
        }
      end
    end
  end
end
