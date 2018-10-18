require 'test_helper'

module HydroponicMongo
  class UpdateTest < ActiveSupport::TestCase
    test 'apply' do
      doc = {'a' => 1}

      Update.apply(doc, {
        '$set' => {
          b: 2,
          c: 3,
        },
        '$rename' => {
          'a' => 'alpha',
        },
        '$unset' => {
          d: true
        },
        '$push' => {
          'a' => {'$each' => [1, 2, 3], '$sort' => -1, '$slice' => 2}
        }
      }, {})
    end

    test '$set' do
      doc = {}
      assert Update.public_send('$set', doc, {a: 1})
      assert_equal 1, doc[:a]

      assert_not Update.public_send('$set', doc, {a: 1})

      assert Update.public_send('$set', doc, {b: 1, c: 1})
      assert_equal 1, doc[:b]
      assert_equal 1, doc[:c]
      assert_not Update.public_send('$set', doc, {b: 1, c: 1})
    end

    test '$inc' do
      doc = {}
      assert Update.public_send('$inc', doc, {a: 1})
      assert_equal 1, doc[:a]
      assert Update.public_send('$inc', doc, {a: 1})
      assert_equal 2, doc[:a]

      assert Update.public_send('$inc', doc, {a: 1, b: 1})
      assert_equal 3, doc[:a]
      assert_equal 1, doc[:b]
    end

    test '$min' do
      doc = {}
      assert Update.public_send('$min', doc, {a: 1})
      assert_equal 1, doc[:a]

      assert_not Update.public_send('$min', doc, {a: 2})
      assert_equal 1, doc[:a]

      assert Update.public_send('$min', doc, {a: 0})
      assert_equal 0, doc[:a]

      assert Update.public_send('$min', doc, {b: 1, c: 2})
      assert_equal 1, doc[:b]
      assert_equal 2, doc[:c]
    end

    test '$max' do
      doc = {}
      assert Update.public_send('$max', doc, {a: 1})
      assert_equal 1, doc[:a]

      assert Update.public_send('$max', doc, {a: 2})
      assert_equal 2, doc[:a]

      assert_not Update.public_send('$max', doc, {a: 0})
      assert_equal 2, doc[:a]

      assert Update.public_send('$max', doc, {b: 1, c: 2})
      assert_equal 1, doc[:b]
      assert_equal 2, doc[:c]
    end

    test '$rename' do
      doc = {}
      assert_not Update.public_send('$rename', doc, {a: :b})
      assert_not doc.key?(:a)

      doc[:a] = 1
      assert Update.public_send('$rename', doc, {a: :b})
      assert_not doc.key?(:a)
      assert_equal 1, doc[:b]

      doc[:a] = 2
      assert Update.public_send('$rename', doc, {b: :c, a: :b, c: :a})
      assert_equal 2, doc[:b]
      assert_equal 1, doc[:a]
    end

    test '$unset' do
      doc = {}
      assert_not Update.public_send('$unset', doc, {a: :b})

      doc = {a: 1, b: 2, c: 3}
      assert Update.public_send('$unset', doc, {a: true})
      assert_not doc.key?(:a)
      assert_not Update.public_send('$unset', doc, {a: true})

      assert Update.public_send('$unset', doc, {b: true, c: 1})
      assert_equal({}, doc)
    end

    test '$push' do
      doc = {}
      assert Update.public_send('$push', doc, {'a' => 1})
      assert_equal [1], doc['a']

      assert Update.public_send('$push', doc, {'a' => 1})
      assert_equal [1, 1], doc['a']

      doc['b'] = {}
      assert_raise(WriteError) do
        Update.public_send('$push', doc, {'b' => 1})
      end

      assert Update.public_send('$push', doc, {'a' => {'$each' => [1, 2, 3]}})
      assert_equal [1, 1, 1, 2, 3], doc['a']

      assert Update.public_send('$push', doc, {'a' => {'$each' => [], '$slice' => -3}})
      assert_equal [1, 2, 3], doc['a']

      assert Update.public_send('$push', doc, {'a' => {'$each' => [], '$slice' => 2}})
      assert_equal [1, 2], doc['a']

      assert Update.public_send('$push', doc, {'a' => {'$each' => [], '$slice' => 0}})
      assert_equal [], doc['a']

      assert Update.public_send('$push', doc, {'a' => {'$each' => [1, 3, 2], '$sort' => -1}})
      assert_equal [3, 2, 1], doc['a']

      assert Update.public_send('$push', doc, {'a' => {'$each' => [4], '$position' => 0}})
      assert_equal [4, 3, 2, 1], doc['a']

      doc['b'] = [{'a' => 1},{'a' => 3},{'a' => 2}]
      assert Update.public_send('$push', doc, {'b' => {'$each' => [{'a' => 0}], '$sort' => {'a' => -1}}})
      assert_equal [{'a' => 3}, {'a' => 2}, {'a' => 1}, {'a' => 0}], doc['b']
    end

    test '$addToSet' do
      doc = {}
      assert Update.public_send('$addToSet', doc, {'a' => 1})
      assert_equal [1], doc['a']

      assert_not Update.public_send('$addToSet', doc, {'a' => 1})

      doc['b'] = {}
      assert_raise(WriteError) do
        Update.public_send('$addToSet', doc, {'b' => 1})
      end

      assert Update.public_send('$addToSet', doc, {'b.c' => {'$each' => [1]}})
      assert_equal [1], doc['b']['c']
      assert Update.public_send('$addToSet', doc, {'b.c' => {'$each' => [1, 2, 3]}})
      assert_equal [1, 2, 3], doc['b']['c']
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
    end
  end
end
