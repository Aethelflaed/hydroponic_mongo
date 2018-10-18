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
    end
  end
end
