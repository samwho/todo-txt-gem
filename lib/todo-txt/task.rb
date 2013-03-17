require 'date'

module Todo
  class Task
    include Comparable

    # The regular expression used to match contexts.
    def self.contexts_regex
       /(?:\s+|^)@\w+/
    end

    # The regex used to match projects.
    def self.projects_regex
       /(?:\s+|^)\+\w+/
    end

    # The regex used to match priorities.
    def self.priotity_regex
      /^\([A-Za-z]\)\s+/
    end

    # The regex used to match dates.
    def self.date_regex
      /(?:\s+|^)([0-9]{4}-[0-9]{2}-[0-9]{2})/
    end

    # The regex used to match completion.
    def self.done_regex
      /^x\s+/
    end

    # Creates a new task. The argument that you pass in must be a string.
    def initialize task
      @orig = task
    end

    # Returns the original content of the task.
    #
    # Example:
    #
    #   task = Todo::Task.new "(A) @context +project Hello!"
    #   task.orig #=> "(A) @context +project Hello!"
    def orig
      @orig
    end

    # Returns the priority, if any.
    #
    # Example:
    #
    #   task = Todo::Task.new "(A) Some task."
    #   task.priority #=> "A"
    #
    #   task = Todo::Task.new "Some task."
    #   task.priority #=> nil
    def priority
      @priority ||= if orig =~ self.class.priotity_regex
        orig[1]
      else
        nil
      end
    end

    # Retrieves an array of all the @context annotations.
    #
    # Example:
    #
    #   task = Todo:Task.new "(A) @context Testing!"
    #   task.context #=> ["@context"]
    def contexts
      @contexts ||= orig.scan(self.class.contexts_regex).map { |item| item.strip }
    end

    # Retrieves an array of all the +project annotations.
    #
    # Example:
    #
    #   task = Todo:Task.new "(A) +test Testing!"
    #   task.projects #=> ["+test"]
    def projects
      @projects ||= orig.scan(self.class.projects_regex).map { |item| item.strip }
    end

    # Gets just the text content of the todo, without the priority, contexts
    # and projects annotations.
    #
    # Example:
    #
    #   task = Todo::Task.new "(A) @test Testing!"
    #   task.text #=> "Testing!"
    def text
      @text ||= orig.
        gsub(self.class.done_regex, '').
        gsub(self.class.date_regex, '').
        gsub(self.class.priotity_regex, '').
        gsub(self.class.contexts_regex, '').
        gsub(self.class.projects_regex, '').
        strip
    end

    # Returns the date present in the task.
    #
    # Example:
    #
    #   task = Todo::Task.new "(A) 2012-03-04 Task."
    #   task.date
    #   #=> <Date: 2012-03-04 (4911981/2,0,2299161)>
    #
    # Dates _must_ be in the YYYY-MM-DD format as specified in the todo.txt
    # format. Dates in any other format will be classed as malformed and this
    # method will return nil.
    def date
      begin
        @date ||= Date.parse(orig.match(self.class.date_regex)[1])
      rescue
        @date = nil
      end
    end

    # Checks whether or not this task is overdue by comparing the task date to
    # the current date.
    #
    # If there is no date specified for this task, this method returns nil.
    #
    # Example:
    #
    #   task = Todo::Task.new "(A) 2012-03-04 Task."
    #   task.overdue?
    #   #=> true
    def overdue?
      return nil if date.nil?
      date < Date.today
    end

    # Returns if the task is done.
    #
    # Example:
    #
    #   task = Todo::Task.new "x 2012-12-08 Task."
    #   task.done?
    #   #=> true
    #
    #   task = Todo::Task.new "Task."
    #   task.done?
    #   #=> false
    def done?
      @done = !(orig =~ self.class.done_regex).nil? if @done.nil?
      @done
    end

    # Completes the task.
    #
    # Example:
    #
    #   task = Todo::Task.new "2012-12-08 Task."
    #   task.done?
    #   #=> false
    #
    #   task.do!
    #   task.done?
    #   #=> true
    def do!
      @done = true
    end

    # Marks the task as incomplete.
    #
    # Example:
    #
    #   task = Todo::Task.new "x 2012-12-08 Task."
    #   task.done?
    #   #=> true
    #
    #   task.undo!
    #   task.done?
    #   #=> false
    def undo!
      @done = false
    end

    # Compares the priorities of two tasks.
    #
    # Example:
    #
    #   task1 = Todo::Task.new "(A) Priority A."
    #   task2 = Todo::Task.new "(B) Priority B."
    #
    #   task1 > task2
    #   # => true
    #
    #   task1 == task2
    #   # => false
    #
    #   task2 > task1
    #   # => false
    def <=> other_task
      if self.priority.nil? and other_task.priority.nil?
        0
      elsif other_task.priority.nil?
        1
      elsif self.priority.nil?
        -1
      else
        other_task.priority <=> self.priority
      end
    end
  end
end
