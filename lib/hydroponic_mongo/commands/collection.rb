# frozen_string_literal: true

module HydroponicMongo
  module Commands
    module Collection
      def collection_insert(cmd)
        reply_hash({'n' => collection.insert(cmd['documents'])})
      end

      def collection_find(cmd)
        cursor("#{database.name}.#{collection.name}",
               collection.find(cmd['filter']))
      end
    end
  end
end
