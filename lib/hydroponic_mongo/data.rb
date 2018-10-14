# frozen_string_literal: true

require 'hydroponic_mongo/database'

module HydroponicMongo
  class Data
    def self.clear
      @servers = nil
    end

    def self.servers
      @servers ||= {}
    end

    def self.new(address)
      servers[address] ||= super(address)
    end

    def initialize(address)
      @address = address
      @databases = Hash.new{|h, k| h[k] = Database.new(self, k)}
    end

    def [](name)
      @databases[name]
    end

    def drop(name)
      @databases.delete name
    end
  end
end
