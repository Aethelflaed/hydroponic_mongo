require 'test_helper'

module HydroponicMongo
  class Query
    class LogicalTest < ActiveSupport::TestCase
      include Query::Logical

      def expression(key, value)
        -> (object) {
          object[key] == object[value]
        }
      end

      test 'and_expressions' do
        assert and_expressions([]).call(nil)

        doc = {a: 1, b: 2, c: 1}
        assert_not and_expressions([{a: :b}, {a: :c}]).call(doc)
        assert and_expressions([{a: :c}]).call(doc)
      end

      test 'nor_expressions' do
        assert nor_expressions([]).call(nil)

        doc = {a: 1, b: 2, c: 1}
        assert_not nor_expressions([{a: :b}, {a: :c}]).call(doc)
        assert_not nor_expressions([{a: :c}]).call(doc)
        assert nor_expressions([{a: :b}, {b: :c}]).call(doc)
      end

      test 'or_expressions' do
        assert_not or_expressions([]).call(nil)

        doc = {a: 1, b: 2, c: 1}
        assert or_expressions([{a: :b}, {a: :c}]).call(doc)
        assert_not or_expressions([{a: :b}]).call(doc)
      end
    end
  end
end
