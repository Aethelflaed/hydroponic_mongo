require 'test_helper'

module HydroponicMongo
  module Commands
    class AdministrationTest < ActiveSupport::TestCase
      include CommandsTestHelper
      include Administration

      test 'listCollections' do
        assert_cursor_reply do
          cmd('listCollections')
        end
        assert_equal [], last_reply.data

        database['foo']

        cmd('listCollections')
        assert_equal 1, last_reply.data.count
        assert_equal "#{database.name}.$cmd.listCollections", last_reply.ns

        bson = last_reply.to_bson
        assert bson['cursor']

        bson = bson['cursor']
        assert bson['firstBatch'].is_a?(Array) && bson['firstBatch'].size == 1
        assert_equal database['foo'].to_bson, bson['firstBatch'][0]
      end

      test 'drop' do
        dtb = database

        assert_hash_reply do
          cmd('drop')
        end

        assert_not Database.all.key?(dtb.name)
        assert_equal dtb.name, last_reply.to_bson['dropped']
      end
    end
  end
end
