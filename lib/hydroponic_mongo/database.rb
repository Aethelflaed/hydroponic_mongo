# frozen_string_literal: true

require 'hydroponic_mongo/collection'

module HydroponicMongo
  class Database
    class << self
      def all
        @databases ||= Hash.new do |hash, name|
          hash[name] = Database.allocate.tap{|dtb| dtb.send(:initialize, name) }
        end
      end

      def new(name)
        all[name]
      end

      def drop(name)
        all.delete(name)
      end
    end

    attr_reader :name

    def initialize(name)
      @name = name
    end

    def collections
      @collections ||= Hash.new{|h, k| h[k] = Collection.new(self, k)}
    end

    delegate :[], to: :collections
    alias_method :collection, :[]

    def drop
      self.class.drop(name)
    end
  end
end
