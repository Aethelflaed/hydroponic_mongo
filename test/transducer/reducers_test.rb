require 'test_helper'

class Transducer
  class ReducersTest < ActiveSupport::TestCase
    test 'push' do
      initial, reducer = Reducers.push

      assert_equal [], initial

      reducer.call(initial, 1)
      assert_equal [1], initial
    end

    test 'uniq' do
      initial, reducer = Reducers.uniq

      assert_equal [], initial

      assert_equal [1], reducer.call(initial, 1)
      assert_equal [1], initial

      assert_equal [1], reducer.call(initial, 1)
      assert_equal [1], initial

      assert_equal [1, 2], reducer.call(initial, 2)
      assert_equal [1, 2], initial
    end

    test 'sum' do
      initial, reducer = Reducers.instance_exec do
        sum 0
      end

      assert_equal 0, initial

      assert_equal 6, [1, 2, 3].reduce(initial, &reducer)
    end

    test 'count' do
      initial, reducer = Reducers.count

      assert_equal 0, initial

      assert_equal 3, [1, 2, 3].reduce(initial, &reducer)
    end

    test 'any?' do
      initial, reducer = Reducers.any?

      res = catch :break do
        [1, 2, 3].reduce(initial, &reducer)
      end
      assert res


      initial, reducer = Reducers.any? {|x| x > 3 }

      res = catch :break do
        [1, 2, 3].reduce(initial, &reducer)
      end
      assert_not res
      res = catch :break do
        [4].reduce(initial, &reducer)
      end
      assert res
    end

    test 'none?' do
      initial, reducer = Reducers.none?

      res = catch :break do
        [1, 2, 3].reduce(initial, &reducer)
      end
      assert_not res

      initial, reducer = Reducers.none? {|x| x > 3 }
      res = catch :break do
        [1, 2, 3].reduce(initial, &reducer)
      end
      assert res
      res = catch :break do
        [4].reduce(initial, &reducer)
      end
      assert_not res
    end

    test 'all?' do
      initial, reducer = Reducers.all?

      res = catch :break do
        [1, 2, 3].reduce(initial, &reducer)
      end
      assert res

      initial, reducer = Reducers.all? {|x| x > 3 }
      res = catch :break do
        [1, 2, 3].reduce(initial, &reducer)
      end
      assert_not res
      res = catch :break do
        [3, 4].reduce(initial, &reducer)
      end
      assert_not res
      res = catch :break do
        [4, 5].reduce(initial, &reducer)
      end
      assert res
    end

    test 'one?' do
      initial, reducer = Reducers.one?

      res = catch :break do
        [1, 2, 3].reduce(initial, &reducer)
      end
      assert_not res
      res = catch :break do
        [1].reduce(initial, &reducer)
      end
      assert res

      initial, reducer = Reducers.one? {|x| x > 3 }
      res = catch :break do
        [1, 2, 3].reduce(initial, &reducer)
      end
      assert_not res
      res = catch :break do
        [1, 2, 3, 4].reduce(initial, &reducer)
      end
      assert res
      res = catch :break do
        [1, 2, 3, 4, 5].reduce(initial, &reducer)
      end
      assert_not res
    end

    test 'find' do
      initial, reducer = Reducers.find

      res = catch :break do
        [1, 2, 3].reduce(initial, &reducer)
      end

      assert_equal 1, res

      initial, reducer = Reducers.find{|x| x > 1}

      res = catch :break do
        [1, 2, 3].reduce(initial, &reducer)
      end

      assert_equal 2, res

      initial, reducer = Reducers.find(false) {|x| x > 3}

      res = catch :break do
        [1, 2, 3].reduce(initial, &reducer)
      end

      assert_equal false, res
    end

    test 'sort' do
      initial, reducer = Reducers.sort

      assert_equal [], initial

      assert_equal [1], reducer.call(initial, 1)
      assert_equal [0, 1], reducer.call(initial, 0)
      assert_equal [0, 1, 3], reducer.call(initial, 3)
      assert_equal [0, 1, 3, 4], reducer.call(initial, 4)
      assert_equal [0, 1, 2, 3, 4], reducer.call(initial, 2)
      assert_equal [0, 1, 2, 2, 3, 4], reducer.call(initial, 2)

      initial, reducer = Reducers.sort{|a, b| a <=> b}

      assert_equal [], initial

      assert_equal [1], reducer.call(initial, 1)
      assert_equal [0, 1], reducer.call(initial, 0)
      assert_equal [0, 1, 3], reducer.call(initial, 3)
      assert_equal [0, 1, 3, 4], reducer.call(initial, 4)
      assert_equal [0, 1, 2, 3, 4], reducer.call(initial, 2)
      assert_equal [0, 1, 2, 2, 3, 4], reducer.call(initial, 2)
    end

    test 'sort_by' do
      Person = Struct.new(:firstname, :age)

      initial, reducer, finalizer = Reducers.sort_by(&:age)

      assert_equal [], initial
      assert finalizer

      p1 = Person.new('Hello', 23)
      p2 = Person.new('JK', 32)
      p3 = Person.new('ufhdjks', 44)
      p4 = Person.new('ioufsjk', 33)
      p5 = Person.new('(8fjke k', 42)
      p6 = Person.new('jklsfbkj ', 3)

      assert_equal [[23, p1]], reducer.call(initial, p1)
      assert_equal [[23, p1], [32, p2]], reducer.call(initial, p2)
      assert_equal [[23, p1], [32, p2], [44, p3]], reducer.call(initial, p3)
      assert_equal [[23, p1], [32, p2], [33, p4], [44, p3]], reducer.call(initial, p4)
      assert_equal [[23, p1], [32, p2], [33, p4], [42, p5], [44, p3]], reducer.call(initial, p5)
      assert_equal [[3, p6], [23, p1], [32, p2], [33, p4], [42, p5], [44, p3]], reducer.call(initial, p6)
    end
  end
end
