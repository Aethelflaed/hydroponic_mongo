require 'test_helper'

module HydroponicMongo
  module Commands
    class AggregationTest < ActiveSupport::TestCase
      include CommandsTestHelper
      include Aggregation

      test 'count' do
        collection.insert_one({'a' => 1})

        assert_hash_reply do
          send_command('count')
        end

        assert_equal 1, last_reply.data['n']

        collection.insert_one({'a' => 2})
        send_command('count')
        assert_equal 2, last_reply.data['n']

        cmd['query'] = {'a' => {'$gt' => 1}}
        send_command('count')
        assert_equal 1, last_reply.data['n']
      end

      test 'distinct' do
        cmd['key'] = 'a.b'
        assert_hash_reply do
          send_command('distinct')
        end

        assert_equal [], last_reply.data['values']

        collection.insert_one({'a' => {'b' => 2}})
        send_command('distinct')
        assert_equal [2], last_reply.data['values']

        collection.insert_one({'a' => {'b' => 2}})
        send_command('distinct')
        assert_equal [2], last_reply.data['values']

        collection.insert_one({'a' => {'b' => 3}})
        send_command('distinct')
        assert_equal [2, 3], last_reply.data['values']
      end
    end
  end
end
