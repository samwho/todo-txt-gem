module Todo
  class List < Array
    # Initializes a Todo List object with a path to the corresponding todo.txt
    # file. For example, if your todo.txt file is located at:
    #
    #   /home/sam/Dropbox/todo/todo.txt
    #
    # You would initialize this object like:
    #
    #   list = Todo::List.new "/home/sam/Dropbox/todo/todo-txt"
    #
    # Alternately, you can initialize this object with an array of strings or
    # tasks. If the array is of strings, the strings will be converted into
    # tasks. You can supply a mixed list of string and tasks if you wish.
    #
    # Example:
    #
    #   array = Array.new
    #   array.push "(A) A string task!"
    #   array.push Todo::Task.new("(A) An actual task!")
    #
    #   list = Todo::List.new array
    def initialize list
      if list.is_a? Array
        # No file path was given.
        @path = nil

        # If path is an array, loop over it, adding to self.
        list.each do |task|
          # If it's a string, make a new task out of it.
          if task.is_a? String
            self.push Todo::Task.new task
          # If it's a task, just add it.
          elsif task.is_a? Todo::Task
            self.push task
          end
        end
      elsif list.is_a? String
        @path = list

        # Read in lines from file, create Todo::Tasks out of them and push them
        # onto self.
        File.open(list) do |file|
          file.each_line { |line| self.push Todo::Task.new line }
        end
      end
    end

    # The path to the todo.txt file that you supplied when you created the
    # Todo::List object.
    def path
      @path
    end

    # Filters the list by priority and returns a new list.
    #
    # Example:
    #
    #   list = Todo::List.new "/path/to/list"
    #   list.by_priority "A" #=> Will be a new list with only priority A tasks
    def by_priority priority
      Todo::List.new self.select { |task| task.priority == priority }
    end

    # Filters the list by context and returns a new list.
    #
    # Example:
    #
    #   list = Todo::List.new "/path/to/list"
    #   list.by_context "@context" #=> Will be a new list with only tasks
    #                                  containing "@context"
    def by_context context
      Todo::List.new self.select { |task| task.contexts.include? context }
    end

    # Filters the list by project and returns a new list.
    #
    # Example:
    #
    #   list = Todo::List.new "/path/to/list"
    #   list.by_project "+project" #=> Will be a new list with only tasks
    #                                  containing "+project"
    def by_project project
      Todo::List.new self.select { |task| task.projects.include? project }
    end
  end
end
