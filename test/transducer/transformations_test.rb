require 'test_helper'

class Transducer
  class TransformationsTest < ActiveSupport::TestCase
    def assert_transformation(fn, name)
      assert((fn.parameters.count == 1 && fn.parameters[0][0] == :block),
             "Expecting #{name} to return a lambda taking a block parameters, got: #{fn.parameters.inspect}")
    end

    def assert_reducer(fn)
      assert((fn.parameters.count == 2 && fn.parameters[0][0] == :req && fn.parameters[1][0] == :req),
             "Expecting reduce function to take two required parameters")
    end

    setup do
      @reducer = -> result, input {
        [result, input]
      }
    end

    test 'map' do
      fn = Transformations.map {|x| x + 1}
      assert_transformation(fn, 'map')
      reducer = fn.call(&@reducer)
      assert_reducer(reducer)

      assert_equal [0, 2], reducer.call(0, 1)
    end

    test 'filter' do
      fn = Transformations.filter {|x| x.even?}
      assert_transformation(fn, 'filter')
      reducer = fn.call(&@reducer)
      assert_reducer(reducer)

      assert_equal 0, reducer.call(0, 1)
      assert_equal [0, 2], reducer.call(0, 2)
    end

    test 'reject' do
      fn = Transformations.reject {|x| x.even?}
      assert_transformation(fn, 'reject')
      reducer = fn.call(&@reducer)
      assert_reducer(reducer)

      assert_equal [0, 1], reducer.call(0, 1)
      assert_equal 0, reducer.call(0, 2)
    end

    test 'unwind' do
      fn = Transformations.unwind {|x, &blk| blk.call(x); blk.call(x)}
      assert_transformation(fn, 'unwind')
      reducer = fn.call(&@reducer)
      assert_reducer(reducer)

      assert_equal [[0, 1], 1], reducer.call(0, 1)
    end

    test 'flatten' do
      fn = Transformations.flatten
      assert_transformation(fn, 'flatten')
      reducer = fn.call(&@reducer)
      assert_reducer(reducer)

      assert_equal [0, 1], reducer.call(0, 1)
      assert_equal [[0, 1], 2], reducer.call(0, [1, 2])
    end

    test 'compact' do
      fn = Transformations.compact
      assert_transformation(fn, 'compact')
      reducer = fn.call(&@reducer)
      assert_reducer(reducer)

      assert_equal [0, 1], reducer.call(0, 1)
      assert_equal 0, reducer.call(0, nil)
    end
  end
end
