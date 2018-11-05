# frozen_string_literal: true

module HydroponicMongo
  module Commands
    module Aggregation
      extend Base

      command 'count' do
        reply_hash({
          'n' => collection.find(cmd['query'], cmd).count
        })
      end

      command 'distinct' do
        path = cmd['key'].split('.', -1)

        query = Query.new(cmd['query'] || {}, collection.documents)
        transducer = query.new_transducer
        transducer.map do |id, doc|
          value_at_path(doc, path)
        end

        transducer.unwind do |value, &blk|
          value.is_a?(Array) ? value.each(&blk) : blk.call(value)
        end

        result = transducer.reduce :distinct

        reply_hash({'values' => result.deep_dup})
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
