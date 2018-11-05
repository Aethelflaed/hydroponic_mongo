# frozen_string_literal: true

module HydroponicMongo
  module Commands
    module Base
      def command(name, &block)
        define_method("$cmd.#{name}", &block)
      end
    end
  end
end
