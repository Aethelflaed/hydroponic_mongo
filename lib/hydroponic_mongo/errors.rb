module HydroponicMongo
  class Error < StandardError
    attr_reader :code
    def initialize(code, errmsg)
      @code = code
      super(errmsg)
    end
  end

  class WriteError < Error
  end
end
