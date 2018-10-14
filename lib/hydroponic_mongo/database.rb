# frozen_string_literal: true

require 'hydroponic_mongo/collection'

module HydroponicMongo
  class Database
    attr_reader :name
    attr_reader :collections

    def initialize(name)
      @name = name
      @collections = Hash.new{|h, name| h[name] = Collection.new(self, name)}
    end

    def [](name)
      @collections[name]
    end
    alias_method :collection, :[]
  end
end
