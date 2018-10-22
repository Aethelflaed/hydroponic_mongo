require 'test_helper'

module HydroponicMongo
  class QueryTest < ActiveSupport::TestCase
    test 'documents' do
      documents = {
        a: {'a' => 1, 'b' => 2},
        b: {'a' => 2, 'b' => 2},
        c: {'a' => 2, 'b' => 1},
        d: {'a' => 1, 'b' => 1},
      }
      expressions = {
        '$and' => [{'a' => 1}, {'b' => 1}],
      }
      options = {}
      assert_equal [{'a' => 1, 'b' => 1}],
        Query.new(expressions, documents, options).documents

      expressions = {
        '$or' => [{'b' => 1}, {'b' => 2}],
        'a' => {'$lt' => 2},
      }
      options['sort'] = {'b' => -1}
      assert_equal [{'a' => 1, 'b' => 2}, {'a' => 1, 'b' => 1}],
        Query.new(expressions, documents, options).documents

      expressions = {
        '$nor' => [{'b' => 2}],
      }
      options['sort'] = {'a' => 1}
      assert_equal [{'a' => 1, 'b' => 1}, {'a' => 2, 'b' => 1}],
        Query.new(expressions, documents, options).documents
    end

    test 'evaluate' do
      @query = Query.new([], {})
      doc = {
        'a' => 1,
        'b' => [1, 2],
        'c' => [{'d' => 1}, {'d' => 2}],
        'd' => {'e' => 1}
      }
      assert @query.evaluate(nil, doc, 1, %w(a))
      assert_not @query.evaluate(nil, doc, {'$ne' => 1}, %w(a))

      assert @query.evaluate(nil, doc, {'e' => 1}, %w(d))
      assert @query.evaluate(nil, doc, 1, %w(b))
      assert @query.evaluate(nil, doc, [1, 2], %w(b))

      assert @query.evaluate(nil, doc, 1, %w(c 0 d))
      assert @query.evaluate(nil, doc, 2, %w(c d))
      assert_equal 1, @query.position

      assert @query.evaluate(nil, doc, {'$exists' => false}, %w(a f))
      assert @query.evaluate(nil, doc, {'$not' => {'$exists' => true}}, %w(a f))
      assert @query.evaluate(nil, doc, {'$not' => false}, %w(a f))
      assert @query.evaluate(nil, doc, {'$ne' => true}, %w(a f))
      assert @query.evaluate(nil, doc, {'$nin' => []}, %w(a f))
      assert_not @query.evaluate(nil, doc, {'$eq' => []}, %w(a f))

      assert_not @query.evaluate(nil, doc, 1, %w(a f))
      assert_not @query.evaluate(nil, doc, 1, %w(e f))
    end
  end
end
