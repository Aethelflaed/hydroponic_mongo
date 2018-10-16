module HydroponicMongo
  class Error < StandardError
    attr_reader :values
    def initialize(type, values)
      super(type)
      @values = values
    end
  end

  class WriteError < Error
    def initialize(hsh)
      super('writeErrors', [hsh])
    end
  end
end
