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
        reply_hash({'values' => collection.distinct(cmd)})
      end
    end
  end
end
