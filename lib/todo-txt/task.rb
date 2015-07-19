require 'date'

module Todo
  class Task
    include Comparable
    include Todo::Logger

    # The regular expression used to match contexts.
    def self.contexts_regex
       /(?:\s+|^)@[^\s]+/
    end

    # The regex used to match projects.
    def self.projects_regex
       /(?:\s+|^)\+[^\s]+/
    end

    # The regex used to match priorities.
    def self.priority_regex
      /(?:^|\s+)\(([A-Za-z])\)\s+/
    end

    # The regex used to match creation date.
    def self.created_on_regex
      /(?:^|-\d{2}\s|\)\s)(\d{4}-\d{2}-\d{2})\s/
    end

    # The regex used to match completion.
    def self.done_regex
      /^x\s+(\d{4}-\d{2}-\d{2})\s+/
    end

    # The regex used to match due date.
    def self.due_on_regex
      /(?:due:)(\d{4}-\d{2}-\d{2})(?:\s+|$)/i
    end

    # Creates a new task. The argument that you pass in must be the string
    # representation of a task.
    #
    # Example:
    #
    #   task = Todo::Task.new("(A) A high priority task!")
    def initialize task
      @orig = task
      @completed_on = get_completed_date #orig.scan(self.class.done_regex)[1] ||= nil
      @priority, @created_on = orig_priority, orig_created_on
      @due_on = get_due_on_date
      @contexts ||= orig.scan(self.class.contexts_regex).map { |item| item.strip }
      @projects ||= orig.scan(self.class.projects_regex).map { |item| item.strip }
    end

    # Returns the original content of the task.
    #
    # Example:
    #
    #   task = Todo::Task.new "(A) @context +project Hello!"
    #   task.orig #=> "(A) @context +project Hello!"
    attr_reader :orig

    # Returns the task's creation date, if any.
    #
    # Example:
    #
    #   task = Todo::Task.new "(A) 2012-03-04 Task."
    #   task.created_on
    #   #=> <Date: 2012-03-04 (4911981/2,0,2299161)>
    #
    # Dates _must_ be in the YYYY-MM-DD format as specified in the todo.txt
    # format. Dates in any other format will be classed as malformed and this
    # attribute will be nil.
    attr_reader :created_on

    # Returns the task's completion date if task is done.
    #
    # Example:
    #
    #   task = Todo::Task.new "x 2012-03-04 Task."
    #   task.completed_on
    #   #=> <Date: 2012-03-04 (4911981/2,0,2299161)>
    #
    # Dates _must_ be in the YYYY-MM-DD format as specified in the todo.txt
    # format. Dates in any other format will be classed as malformed and this
    # attribute will be nil.
    attr_reader :completed_on

    # Returns the task's due date, if any.
    #
    # Example:
    #
    #   task = Todo::Task.new "(A) This is a task. due:2012-03-04"
    #   task.due_on
    #   #=> <Date: 2012-03-04 (4911981/2,0,2299161)>
    #
    # Dates _must_ be in the YYYY-MM-DD format as specified in the todo.txt
    # format. Dates in any other format will be classed as malformed and this
    # attribute will be nil.
    attr_reader :due_on

    # Returns the priority, if any.
    #
    # Example:
    #
    #   task = Todo::Task.new "(A) Some task."
    #   task.priority #=> "A"
    #
    #   task = Todo::Task.new "Some task."
    #   task.priority #=> nil
    attr_reader :priority

    # Returns an array of all the @context annotations.
    #
    # Example:
    #
    #   task = Todo:Task.new "(A) @context Testing!"
    #   task.context #=> ["@context"]
    attr_reader :contexts

    # Returns an array of all the +project annotations.
    #
    # Example:
    #
    #   task = Todo:Task.new "(A) +test Testing!"
    #   task.projects #=> ["+test"]
    attr_reader :projects

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
        gsub(self.class.priority_regex, '').
        gsub(self.class.created_on_regex, '').
        gsub(self.class.contexts_regex, '').
        gsub(self.class.projects_regex, '').
        gsub(self.class.due_on_regex, '').
        strip
    end

    # Returns the task's creation date, if any.
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
    #
    # Deprecated
    def date
      logger.warn("Task#date is deprecated, use created_on instead.")

      @created_on
    end

    # Returns whether a task's due date is in the past.
    #
    # Example:
    #
    #   task = Todo::Task.new("This task is overdue! due:#{Date.today - 1}")
    #   task.overdue?
    #   #=> true
    def overdue?
      return true if !due_on.nil? && due_on < Date.today
      false
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
      !@completed_on.nil?
    end

    # Completes the task on the current date.
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
    #   task.created_on
    #   #=> <Date: 2012-12-08 (4911981/2,0,2299161)>
    #   task.completed_on
    #   #=> # the current date
    def do!
      @completed_on = Date.today
      @priority = nil
    end

    # Marks the task as incomplete and resets its original priority.
    #
    # Example:
    #
    #   task = Todo::Task.new "x 2012-12-08 2012-03-04 Task."
    #   task.done?
    #   #=> true
    #
    #   task.undo!
    #   task.done?
    #   #=> false
    #   task.created_on
    #   #=> <Date: 2012-03-04 (4911981/2,0,2299161)>
    #   task.completed_on
    #   #=> nil
    def undo!
      @completed_on = nil
      @priority = orig_priority
    end

    # Toggles the task from complete to incomplete or vice versa.
    #
    # Example:
    #
    #   task = Todo::Task.new "x 2012-12-08 Task."
    #   task.done?
    #   #=> true
    #
    #   task.toggle!
    #   task.done?
    #   #=> false
    #
    #   task.toggle!
    #   task.done?
    #   #=> true
    def toggle!
      done? ? undo! : do!
    end

    # Returns this task as a string.
    #
    # Example:
    #
    #   task = Todo::Task.new "(A) 2012-12-08 Task"
    #   task.to_s
    #   #=> "(A) 2012-12-08 Task"
    def to_s
      priority_string = priority ? "(#{priority}) " : ""
      done_string = done? ? "x #{completed_on} " : ""
      created_on_string = created_on ? "#{created_on} " : ""
      contexts_string = contexts.empty? ? "" : " #{contexts.join ' '}"
      projects_string = projects.empty? ? "" : " #{projects.join ' '}"
      due_on_string = due_on.nil? ? "" : " due:#{due_on}"
      "#{done_string}#{priority_string}#{created_on_string}#{text}#{contexts_string}#{projects_string}#{due_on_string}"
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

    private

    def orig_priority
      @orig.match(self.class.priority_regex)[1] if @orig =~ self.class.priority_regex
    end

    def orig_created_on
      begin
        if @orig =~ self.class.created_on_regex
          date = @orig.match self.class.created_on_regex
          return Date.parse(date[1]) unless date.nil?
        end
      rescue; end
      nil
    end

    def get_completed_date
      begin
        return Date.parse(self.class.done_regex.match(@orig)[1])
      rescue; end
      nil
    end

    def get_due_on_date
      begin
        return Date.parse(self.class.due_on_regex.match(@orig)[1])
      rescue; end
      nil
    end

  end
end
