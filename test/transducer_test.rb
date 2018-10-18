require 'test_helper'

class TransducerTest < ActiveSupport::TestCase
  test 'eval' do
    @transducer = Transducer.eval([1, 2, 3]) do
      map{|x| x + 1}
      filter{|x| x.even?}
    end

    assert_kind_of Transducer, @transducer
    assert_equal [2, 4], @transducer.to_a

    assert_raise(Transducer::AlreadyReducedError) do
      @transducer.eval do
      end
    end
  end

  test 'map' do
    @transducer = Transducer.new([1, 2, 3])
    assert_equal @transducer, @transducer.map{|x| x + 1}

    assert_equal [2, 3, 4], @transducer.to_a

    assert_raise(Transducer::AlreadyReducedError) do
      @transducer.map
    end
  end

  test 'filter' do
    @transducer = Transducer.new([1, 2, 3])
    assert_equal @transducer, @transducer.filter{|x| x.even?}

    assert_equal [2], @transducer.to_a

    assert_raise(Transducer::AlreadyReducedError) do
      @transducer.filter
    end
  end

  test 'reject' do
    @transducer = Transducer.new([1, 2, 3])
    assert_equal @transducer, @transducer.reject{|x| x.even?}

    assert_equal [1, 3], @transducer.to_a

    assert_raise(Transducer::AlreadyReducedError) do
      @transducer.reject
    end
  end

  test 'compact' do
    @transducer = Transducer.new([nil, 2, 3])
    assert_equal @transducer, @transducer.compact

    assert_equal [2, 3], @transducer.to_a

    assert_raise(Transducer::AlreadyReducedError) do
      @transducer.compact
    end
  end

  test 'flatten' do
    @transducer = Transducer.new([[1], 2, 3])
    assert_equal @transducer, @transducer.flatten

    assert_equal [1, 2, 3], @transducer.to_a

    @transducer = Transducer.new([[1], 2, 3])
    assert_equal @transducer, @transducer.flatten(0)

    assert_equal [[1], 2, 3], @transducer.to_a

    @transducer = Transducer.new([[1], [[2], 3]])
    assert_equal @transducer, @transducer.flatten(1)

    assert_equal [1, [2], 3], @transducer.to_a

    assert_raise(Transducer::AlreadyReducedError) do
      @transducer.flatten
    end
  end

  test 'unwind' do
    @transducer = Transducer.new([1, 2, 3])
    assert_equal @transducer, @transducer.unwind{|x, &blk| 2.times{blk.call(x)}}

    assert_equal [1, 1, 2, 2, 3, 3], @transducer.to_a

    assert_raise(Transducer::AlreadyReducedError) do
      @transducer.unwind
    end
  end

  test 'reduce' do
    @transducer = Transducer.new([1, 2, 3])
    assert_equal 6, @transducer.reduce(:sum)

    @transducer = Transducer.new([1, 2, 3])
    assert_equal(3, @transducer.reduce { count } )

    @transducer = Transducer.new([1, 2, 3])
    assert_raise(ArgumentError) do
      @transducer.reduce
    end

    @transducer = Transducer.new([1, 2, 3])
    assert_equal 7, @transducer.reduce(:sum, 1)

    assert_raise(Transducer::AlreadyReducedError) do
      @transducer.reduce
    end
  end

  test 'reduce with finalizer' do
    Person = Struct.new(:firstname, :age)

    p1 = Person.new('Hello', 23)
    p2 = Person.new('JK', 32)
    p3 = Person.new('ufhdjks', 44)
    p4 = Person.new('ioufsjk', 33)
    p5 = Person.new('(8fjke k', 42)
    p6 = Person.new('jklsfbkj ', 3)

    enum = [p1, p2, p3, p4, p5, p6]

    @transducer = Transducer.new(enum)
    assert_equal [p6, p1, p2, p4, p5, p3], @transducer.reduce{sort_by(&:age)}
  end
end
