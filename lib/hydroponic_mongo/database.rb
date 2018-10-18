# frozen_string_literal: true

require 'hydroponic_mongo/collection'

module HydroponicMongo
  class Database
    attr_reader :name
    attr_reader :collections

    def initialize(server, name)
      @server = server
      @name = name
      @collections = Hash.new{|h, k| h[k] = Collection.new(self, k)}
    end

    def [](name)
      @collections[name]
    end
    alias_method :collection, :[]

    def drop
      @server.dropDatabase(name)
    end
  end
end
