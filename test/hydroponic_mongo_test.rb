require "test_helper"

class HydroponicMongoTest < ActiveSupport::TestCase
  test 'client' do
    @client = Mongo::Client.new('mongodb://127.0.0.1:27017/test')

    @client.cluster.servers.each do |server|
      assert_kind_of HydroponicMongo::Server, server
    end
  end
end
