require 'test_helper'

class Transducer
  class ReducersTest < ActiveSupport::TestCase
    test 'push' do
      initial, reducer = Reducers.push

      assert_equal [], initial

      reducer.call(initial, 1)
      assert_equal [1], initial
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
  end
end
