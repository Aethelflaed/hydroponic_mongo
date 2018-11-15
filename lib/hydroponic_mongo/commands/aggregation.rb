# frozen_string_literal: true

module HydroponicMongo
  module Commands
    module Aggregation
      extend Base

      command 'count' do
        query = Query.new(cmd['query'], collection.documents, cmd)

        reply_hash({
          'n' => query.documents.count
        })
      end

      command 'distinct' do
        path = cmd['key'].split('.', -1)

        query = Query.new(cmd['query'] || {}, collection.documents)
        transducer = query.transducer
        transducer.map do |id, doc|
          value_at_path(doc, path)
        end

        transducer.unwind do |value, &blk|
          value.is_a?(Array) ? value.each(&blk) : blk.call(value)
        end

        result = transducer.reduce :distinct

        reply_hash({'values' => result})
      end

      def value_at_path(doc, path)
        first, *rest = path
        if first
          value_at_path(doc[first], rest)
        else
          return doc
        end
      end
    end
  end
end
