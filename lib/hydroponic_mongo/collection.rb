module HydroponicMongo
  class Collection
    def initialize(database, name)
      @database = database
      @name = name
      @type = 'collection'
      @info = {'readOnly' => false}
      @documents = {}
    end
  end
end
