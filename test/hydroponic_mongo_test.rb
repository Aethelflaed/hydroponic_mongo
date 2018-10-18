require "test_helper"

class HydroponicMongoTest < ActiveSupport::TestCase
  setup do
    @client = Mongo::Client.new('mongodb://127.0.0.1:27017/test')
    @db = @client['foo']
  end

  test 'client' do
    @client.cluster.servers.each do |server|
      assert_kind_of HydroponicMongo::Server, server
    end
  end

  test 'basic behavior' do
    @db.insert_one({
      a: 1
    })
    result = @db.find.to_a
    assert_equal 1, result.size
    assert_kind_of BSON::ObjectId, result[0]['_id']

    @db.insert_many([
      {
        a: 2,
        b: [2, 3]
      },
      {
        a: 3,
        b: [4, 5],
        c: [
          {d: 6},
          {d: 7},
          {e: [{f: 1}, {f: 3}]},
        ]
      }
    ])

    assert_equal 3, @db.find.count

    @db.find(a: {'$lt' => 4}).update_many({
      '$set' => {
        d: 4
      }
    })

    @db.find(a: {'$lt' => 3, '$gt' => 1}).update_one({
      '$rename' => {
        b: 'd'
      }
    })

    @db.find(a: 4).update_many({
      '$set' => {
        _id: 4,
        a: 4,
        b: 3
      }
    }, upsert: true)

    assert_equal 4, @db.find(_id: 4).first['a']

    assert_equal [4, 3, 2, 1], @db.find({}).sort('a' => -1).map{|x| x['a']}
  end
end
