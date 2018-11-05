module CommandsTestHelper
  extend ActiveSupport::Concern

  included do
    setup do
      @replies = []
    end

    teardown do
      @database&.drop
      @database = nil
    end
  end

  def database
    @database ||= HydroponicMongo::Database.new("#{self.class.name.underscore}_#{@NAME}")
  end

  def cmd(name)
    public_send("$cmd.#{name}")
  end

  def last_reply
    @replies.last&.last
  end

  def assert_cursor_reply
    if block_given?
      assert_reply(type: :cursor, &Proc.new)
    else
      assert_reply(type: :cursor)
    end
  end

  def assert_hash_reply
    if block_given?
      assert_reply(type: :hash, &Proc.new)
    else
      assert_reply(type: :hash)
    end
  end

  def assert_reply(*args)
    if block_given?
      begin
        replies = @replies
        @replies = []
        yield
        assert_reply(*args)
      ensure
        @replies = replies + @replies
      end
    else
      options = args.extract_options!
      n = args.first || 1

      if n == 1
        if @replies.count == 1
          if options[:type]
            assert @replies.last[0] == options[:type],
              "Expected a #{options[:type]} reply, got #{@replies.last[0]}"
          else
            assert true
          end
        else
          assert false,
            "Expected 1 reply, got #{@replies.count}"
        end
      else
        assert @replies.count == n,
          "Expected #{n} replies, got #{@replies.count}"
      end
    end
  end

  def reply_cursor(name, values)
    @replies.push([:cursor, HydroponicMongo::Reply::Cursor.new(name, values)])
  end

  def reply_hash(values)
    @replies.push([:hash, HydroponicMongo::Reply::Hash.new(values)])
  end
end
