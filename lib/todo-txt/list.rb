module Todo
  class List < Array
    # Initializes a Todo List object with a path to the corresponding todo.txt
    # file. For example, if your todo.txt file is located at:
    #
    #   /home/sam/Dropbox/todo/todo.txt
    #
    # You would initialize this object like do:
    #
    #   list = Todo::List.new "/home/sam/Dropbox/todo/todo-txt"
    def initialize path
      @path = path

      # Read in lines from file, create Todo::Tasks out of them and push them
      # onto self.
      File.open(path) do |file|
        file.each_line { |line| self.push Todo::Task.new line }
      end
    end

    # The path to the todo.txt file that you supplied when you created the
    # Todo::List object.
    def path
      @path
    end
  end
end
