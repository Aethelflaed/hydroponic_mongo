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

  CommandNotImplementedError = Class.new(NotImplementedError) do
    def initialize(payload)
      super("Not implemented: #{payload.inspect}")
    end
  end

  UpdateOperatorNotImplementedError = Class.new(NotImplementedError) do
    def initialize(op)
      super("Not implemented update operator #{op}")
    end
  end

  QueryOperatorNotImplementedError = Class.new(NotImplementedError) do
    def initialize(query, op, arg, doc)
      super("In query #{query.inspect}, don't know how to handle #{op} => #{arg} for #{doc}")
    end
  end
end
