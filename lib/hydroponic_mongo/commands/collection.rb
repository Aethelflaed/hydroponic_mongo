# frozen_string_literal: true

module HydroponicMongo
  module Commands
    module Collection
      def collection_insert(cmd)
        reply_hash({'n' => collection.insert(cmd['documents'])})
      end

      def collection_find(cmd)
        cursor("#{database.name}.#{collection.name}",
               collection.find(cmd['filter'], cmd))
      end

      def collection_update(cmd)
        count, nModified = 0, 0
        cmd['updates'].each do |update|
          c, n = collection.update(update['q'], update['u'], update)
          count += c
          nModified += n
        end

        reply_hash({'n' => count, 'nModified' => nModified})
      rescue HydroponicMongo::Error => e
        rval = {'n' => count, 'nModified' => nModified}
        rval[e.message] = e.values
        reply_hash(rval)
      end

      def collection_findAndModify(cmd)
        raise NotImplementedError.new
      end
    end
  end
end
