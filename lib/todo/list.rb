module Todo
  # Initializes a Todo List object with a path to the corresponding todo.txt
  # file. For example, if your todo.txt file is located at:
  #
  #   /home/sam/Dropbox/todo/todo.txt
  #
  # You would initialize the list object like:
  #
  #   list = Todo::List.new("/home/sam/Dropbox/todo/todo.txt")
  #
  # Alternately, you can initialize the object with an array of strings or
  # tasks. If the array is of strings, the strings will be converted into
  # tasks. You can supply a mixed list of string and tasks if you wish.
  #
  # Example:
  #
  #   tasks = []
  #   tasks << "A task line"
  #   tasks << Todo::Task.new("A task object")
  #
  #   list = Todo::List.new(tasks)
  class List < Array
    def initialize(list)
      if list.is_a? Array
        # No file path was given.
        @path = nil

        # If path is an array, loop over it, adding to self.
        list.each do |task|
          # If it's a string, make a new task out of it.
          if task.is_a? String
            push Task.new task
          # If it's a task, just add it.
          elsif task.is_a? Todo::Task
            push task
          end
        end
      elsif list.is_a? String
        @path = list

        # Read in lines from file, create Todo::Tasks out of them and push them
        # onto self.
        File.open(list) do |file|
          file.each_line { |line| push Task.new(line) }
        end
      end
    end

    # The path to the todo.txt file that you supplied when you created the
    # Todo::List object.
    attr_reader :path

    # Filters the list by priority and returns a new list.
    #
    # Example:
    #
    #   list = Todo::List.new("/path/to/list")
    #   list.by_priority("A")
    #   # => Will be a new list with only priority 'A' tasks
    #
    # @param priority [String]
    # @return [Todo::List]
    def by_priority(priority)
      List.new(select { |task| task.priority == priority })
    end

    # Filters the list by context and returns a new list.
    #
    # Example:
    #
    #   list = Todo::List.new("/path/to/list")
    #   list.by_context("@admin")
    #   # => <Todo::List> filtered by '@admin'
    #
    # @param context [String]
    # @return [Todo::List]
    def by_context(context)
      List.new(select { |task| task.contexts.include? context })
    end

    # Filters the list by project and returns a new list.
    #
    # Example:
    #
    #   list = Todo::List.new("/path/to/list")
    #   list.by_project("+blog")
    #   # => <Todo::List> filtered by '+blog'
    #
    # @param project [String]
    # @return [Todo::List]
    def by_project(project)
      List.new(select { |task| task.projects.include? project })
    end

    # Filters the list by completed tasks and returns a new list.
    #
    # Example:
    #
    #   list = Todo::List.new("/path/to/list")
    #   list.by_done
    #   # => <Todo::List> filtered by tasks that are done
    #
    # @return [Todo::List]
    def by_done
      List.new(select(&:done?))
    end

    # Filters the list by incomplete tasks and returns a new list.
    #
    # Example:
    #
    #   list = Todo::List.new("/path/to/list")
    #   list.by_not_done
    #   # => <Todo::List> filtered by tasks that are not done
    #
    # @return [Todo::List]
    def by_not_done
      List.new(select { |task| task.done? == false })
    end

    # Saves the list to the original file location.
    #
    # Warning: This is a destructive operation and will overwrite any existing
    # content in the file. It does not attempt to diff and append changes.
    #
    # If no `path` is specified in the constructor then an error is raised.
    def save!
      raise "No path specified." unless path

      File.open(path, 'w') do |outfile|
        each do |task|
          outfile.puts(task.to_s)
        end
      end
    end
  end
end
