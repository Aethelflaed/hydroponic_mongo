# frozen_string_literal: true

module HydroponicMongo
  module Commands
    module Database
      def database_listCollections
        cursor("#{database.name}.$cmd.listCollections",
               database.collections.values)
      end
    end
  end
end
