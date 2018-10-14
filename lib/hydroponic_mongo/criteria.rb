# frozen_string_literal: true

module HydroponicMongo
  module Criterion
  end

  class Criteria
    def initialize(filter)
      @filter = filter
    end

    def empty?
      @filter.size == 0
    end

    def id?
      @filter.size == 1 && @filter.key?('_id')
    end
    def id
      @filter['_id']
    end

    def each
      @filter.each do |criterion|
        yield Criteria.factory(*criterion)
      end
    end

    def self.factory(key, value)
      case key
      when '$or'
        -> (doc) {
          value.any? do |criteria|
            criteria.all? do |criterion|
              factory(*criterion).call(doc)
            end
          end
        }
      when '$and'
        -> (doc) {
          value.all? do |criteria|
            criteria.all? do |criterion|
              factory(*criterion).call(doc)
            end
          end
        }
      else
        Criterion::Field.to_proc(key, value)
      end
    end
  end
end

require 'hydroponic_mongo/criteria/field'
require 'hydroponic_mongo/criteria/or'
require 'hydroponic_mongo/criteria/query_selector'
