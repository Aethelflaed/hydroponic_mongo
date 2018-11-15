require 'test_helper'

module HydroponicMongo
  class Query
    class ValueExprTest < ActiveSupport::TestCase
      test '$eq' do
        assert ValueExpr.public_send('$eq', 1, 1)
        assert ValueExpr.public_send('$eq', 'hello', /[a-z]+/)
      end

      test '$regex' do
        assert ValueExpr.public_send('$regex', 'hello', /[a-z]+/)
        assert ValueExpr.public_send('$regex', 'hello', '[a-z]+')
      end

      test '$ne' do
        assert_not ValueExpr.public_send('$ne', 1, 1)
      end

      test '$gt' do
        assert_not ValueExpr.public_send('$gt', 1, 1)
      end

      test '$gte' do
        assert ValueExpr.public_send('$gte', 1, 1)
      end

      test '$lt' do
        assert_not ValueExpr.public_send('$lt', 1, 1)
      end

      test '$lte' do
        assert ValueExpr.public_send('$lte', 1, 1)
      end

      test '$in' do
        assert ValueExpr.public_send('$in', 1, [1, 2])
      end

      test '$nin' do
        assert_not ValueExpr.public_send('$nin', 1, [1, 2])
      end

      test '$exists' do
        assert ValueExpr.public_send('$exists', true, false)
      end
    end
  end
end
