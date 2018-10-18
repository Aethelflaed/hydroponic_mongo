# frozen_string_literal: true

module HydroponicMongo
  module Commands
    module Database
      def database_listCollections
        cursor("#{database.name}.$cmd.listCollections",
               database.collections.values)
      end

      def database_drop
        database.drop

        reply_hash({'dropped' => database.name})
      end
    end
  end
end
