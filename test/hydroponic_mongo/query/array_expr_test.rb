require 'test_helper'

module HydroponicMongo
  class Query
    class ArrayExprTest < ActiveSupport::TestCase
      test '$eq' do
        assert ArrayExpr.public_send('$eq', [1], [1])
        assert ArrayExpr.public_send('$eq', [1], 1)
      end

      test '$ne' do
        assert_not ArrayExpr.public_send('$ne', [1], [1])
        assert_not ArrayExpr.public_send('$ne', [1], 1)
      end

      test '$in' do
        assert ArrayExpr.public_send('$in', [1], [1, 2])
      end

      test '$nin' do
        assert ArrayExpr.public_send('$nin', [3], [1, 2])
      end

      test '$size' do
        assert ArrayExpr.public_send('$size', [], 0)
        assert_not ArrayExpr.public_send('$size', [], 1)
        assert ArrayExpr.public_send('$size', [1, 2, 3], 3)
      end

      test '$elemMatch' do
        assert ArrayExpr.public_send('$elemMatch', [1, 3], {'$gt' => 2})
        assert_not ArrayExpr.public_send('$elemMatch', [1, 3], {'$lt' => 1})

        docs = [
          {'a' => 1, 'b' => 20},
          {'a' => 2, 'b' => 10},
          {'a' => 3, 'b' => 5},
        ]

        assert ArrayExpr.public_send('$elemMatch', docs, {
          'a' => {'$gt' => 1},
          'b' => {'$lt' => 10}
        })
      end
    end
  end
end
