module Todo
  # A high level wrapper around the Ruby File interface which supports reading
  # from and writing to an IO handle with Todo::Task objects.
  class File
    # Open a list file handle and pass it to the given block. The file is
    # automatically closed when the block returns.
    #
    # The file is opened in read-only mode by default.
    #
    #  Todo::File.open("~/Dropbox/todo/todo.txt") do |file|
    #    file.each_task do |task|
    #      puts task.done?
    #    end
    #  end
    #
    # @param [String, Pathname] path
    # @param [String] mode
    def self.open(path, mode = 'r')
      ios = new(path, mode)

      if block_given?
        yield ios
        return ios.close
      end

      ios
    end

    # @param [String, Pathname] path
    def self.read(path)
      list = []

      open(path) do |file|
        file.each_task do |task|
          list << task
        end
      end

      list
    end

    # @param [String, Pathname] path
    # @param [Array, Todo::List] list
    def self.write(path, list)
      open(path, 'w') do |file|
        list.each do |task|
          file.puts(task)
        end
      end
    end

    # @param [String, Pathname] path
    # @param [String] mode
    def initialize(path, mode = 'r')
      @ios = ::File.open(path, mode)
    end

    # Executes the block for every task in the list.
    def each
      return enum_for(:each) unless block_given?

      @ios.each_line do |line|
        yield Task.new(line)
      end
    end

    alias each_task each

    # Writes the given tasks to the underlying IO handle.
    #
    # @overload puts(task, ...)
    #   @param [Todo::Task] task
    #   @param [Todo::Task] ...
    def puts(*tasks)
      @ios.puts(tasks.map(&:to_s))
    end

    # Closes the IO handle and flushes any pending writes.
    def close
      @ios.close
    end
  end
end
