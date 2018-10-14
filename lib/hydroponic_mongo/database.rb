require 'hydroponic_mongo/collection'
require 'hydroponic_mongo/cursor'

module HydroponicMongo
  class Database
    attr_reader :name

    def initialize(name)
      @name = name
      @collections = {}
      @indices = {}
    end

    def command(connection, cmd)
      if cmd['listCollections']
        listCollections(connection, cmd)
      else
        raise StandardError.new("Check how to handle: #{cmd.inspect}")
      end
    end

    def listCollections(connection, cmd)
      data = @collections.keys
      connection.reply Cursor.new("#{name}.$cmd.listCollections", data)
    end
  end
end
