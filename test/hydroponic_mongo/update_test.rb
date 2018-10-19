require 'test_helper'

module HydroponicMongo
  class UpdateTest < ActiveSupport::TestCase
    test 'apply' do
      doc = {'a' => 1}

      Update.apply(doc, {
        '$set' => {
          'b' => 2,
          'c' => 3,
        },
        '$rename' => {
          'a' => 'alpha',
        },
        '$unset' => {
          'd' => true
        },
        '$push' => {
          'a' => {'$each' => [1, 2, 3], '$sort' => -1, '$slice' => 2}
        }
      }, {})

      assert_raise(WriteError) do
        Update.apply(doc, {
          '$set' => { 'h' => {} },
          '$push' => { 'h' => 1 }
        }, {})
      end
    end

    test '$set' do
      doc = {}
      assert Update.public_send('$set', doc, :a, 1)
      assert_equal 1, doc[:a]

      assert_not Update.public_send('$set', doc, :a, 1)
    end

    test '$inc' do
      doc = {}
      assert Update.public_send('$inc', doc, :a, 1)
      assert_equal 1, doc[:a]
      assert Update.public_send('$inc', doc, :a, 1)
      assert_equal 2, doc[:a]
    end

    test '$min' do
      doc = {}
      assert Update.public_send('$min', doc, :a, 1)
      assert_equal 1, doc[:a]

      assert_not Update.public_send('$min', doc, :a, 2)
      assert_equal 1, doc[:a]

      assert Update.public_send('$min', doc, :a, 0)
      assert_equal 0, doc[:a]
    end

    test '$max' do
      doc = {}
      assert Update.public_send('$max', doc, :a, 1)
      assert_equal 1, doc[:a]

      assert Update.public_send('$max', doc, :a, 2)
      assert_equal 2, doc[:a]

      assert_not Update.public_send('$max', doc, :a, 0)
      assert_equal 2, doc[:a]
    end

    test '$rename' do
      doc = {}
      assert_not Update.public_send('$rename', doc, :a, :b)
      assert_not doc.key?(:a)

      doc[:a] = 1
      assert Update.public_send('$rename', doc, :a, :b)
      assert_not doc.key?(:a)
      assert_equal 1, doc[:b]
    end

    test '$unset' do
      doc = {}
      assert_not Update.public_send('$unset', doc, :a, :b)

      doc = {a: 1}
      assert Update.public_send('$unset', doc, :a, true)
      assert_not doc.key?(:a)
      assert_not Update.public_send('$unset', doc, :a, true)
    end

    test '$push' do
      doc = {}
      assert Update.public_send('$push', doc, 'a', 1)
      assert_equal [1], doc['a']

      assert Update.public_send('$push', doc, 'a', 1)
      assert_equal [1, 1], doc['a']

      doc['b'] = {}
      assert_raise(Update::ArrayExpected) do
        Update.public_send('$push', doc, 'b', 1)
      end

      assert Update.public_send('$push', doc, 'a', {'$each' => [1, 2, 3]})
      assert_equal [1, 1, 1, 2, 3], doc['a']

      assert Update.public_send('$push', doc, 'a', {'$each' => [], '$slice' => -3})
      assert_equal [1, 2, 3], doc['a']

      assert Update.public_send('$push', doc, 'a', {'$each' => [], '$slice' => 2})
      assert_equal [1, 2], doc['a']

      assert Update.public_send('$push', doc, 'a', {'$each' => [], '$slice' => 0})
      assert_equal [], doc['a']

      assert Update.public_send('$push', doc, 'a', {'$each' => [1, 3, 2], '$sort' => -1})
      assert_equal [3, 2, 1], doc['a']

      assert Update.public_send('$push', doc, 'a', {'$each' => [4], '$position' => 0})
      assert_equal [4, 3, 2, 1], doc['a']

      doc['b'] = [{'a' => 1},{'a' => 3},{'a' => 2}]
      assert Update.public_send('$push', doc, 'b', {'$each' => [{'a' => 0}], '$sort' => {'a' => -1}})
      assert_equal [{'a' => 3}, {'a' => 2}, {'a' => 1}, {'a' => 0}], doc['b']
    end

    test '$addToSet' do
      doc = {}
      assert Update.public_send('$addToSet', doc, 'a', 1)
      assert_equal [1], doc['a']

      assert_not Update.public_send('$addToSet', doc, 'a', 1)

      doc['b'] = {}
      assert_raise(Update::ArrayExpected) do
        Update.public_send('$addToSet', doc, 'b', 1)
      end

      assert Update.public_send('$addToSet', doc, 'c', {'$each' => [1]})
      assert_equal [1], doc['c']
      assert Update.public_send('$addToSet', doc, 'c', {'$each' => [1, 2, 3]})
      assert_equal [1, 2, 3], doc['c']
    end

    test 'resolve_field_path' do
      doc = {'a' => {'b' => {'c' => 1}}}

      assert_equal [doc['a']['b'], 'c'],
        Update.resolve_field_path(doc, '', %w(a b c))
      assert_equal [doc['a']['b'], 'd'],
        Update.resolve_field_path(doc, '', %w(a b d))

      assert_raise(WriteError) do
        Update.resolve_field_path(doc, '', %w(d d d ))
      end

      doc = {'a' => [{'b' => 1}, {'b' => {'c' => 1}}]}

      assert_equal [doc['a'][0], 'b'],
        Update.resolve_field_path(doc, '', %w(a 0 b))

      assert_equal [doc['a'][1], 'b'],
        Update.resolve_field_path(doc, '', %w(a $ b), {'position' => 1})

      assert_raise(WriteError) do
        Update.resolve_field_path(doc, '', %w(a c b))
      end
    end
  end
end
