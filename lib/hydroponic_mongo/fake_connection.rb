# frozen_string_literal: true

module HydroponicMongo
  module FakeConnection
    def connect!
      true
    end

    def disconnect!
      true
    end

    def ensure_connected
      yield self
    end
  end
end
