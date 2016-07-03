require 'date'

module Todo
  # Creates a new task. The argument that you pass in must be the string
  # representation of a task.
  #
  # Example:
  #
  #   task = Todo::Task.new("(A) A high priority task!")
  class Task
    include Comparable
    include Todo::Logger
    include Todo::Syntax

    def initialize(line)
      @raw = line
      @priority = extract_priority(raw)
      @created_on = extract_created_on(raw)
      @tags = extract_tags(raw)
      @contexts ||= extract_contexts(raw)
      @projects ||= extract_projects(raw)

      if Todo.options.require_completed_on
        @completed_on = extract_completed_date(raw)
        @is_completed = !@completed_on.nil?
      else
        @completed_on = extract_completed_date(raw)
        @is_completed = check_completed_flag(raw)
      end
    end

    # Returns the raw content of the original task line.
    #
    # Example:
    #
    #   task = Todo::Task.new("(A) @context +project Hello!")
    #   task.raw
    #   # => "(A) @context +project Hello!"
    attr_reader :raw

    # Returns the task's creation date, if any.
    #
    # Example:
    #
    #   task = Todo::Task.new("(A) 2012-03-04 Task.")
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
    #   task = Todo::Task.new("x 2012-03-04 Task.")
    #   task.completed_on
    #   # => <Date: 2012-03-04 (4911981/2,0,2299161)>
    #
    # Dates _must_ be in the YYYY-MM-DD format as specified in the todo.txt
    # format. Dates in any other format will be classed as malformed and this
    # attribute will be nil.
    attr_reader :completed_on

    # Returns tag annotations embedded in the list item.
    #
    # Example:
    #
    #   task = Todo::Task.new("Some task. due:2016-06-16 hello:world")
    #   task.tags
    #   # => { :due => '2016-06-16', :hello => 'world' }
    #
    #   task = Todo::Task.new("Some task.")
    #   task.tags.empty?
    #   # => true
    attr_reader :tags

    # Returns the priority, if any.
    #
    # Example:
    #
    #   task = Todo::Task.new("(A) Some task.")
    #   task.priority
    #   # => "A"
    #
    #   task = Todo::Task.new "Some task."
    #   task.priority
    #   # => nil
    attr_reader :priority

    # Returns an array of all the @context annotations.
    #
    # Example:
    #
    #   task = Todo:Task.new("(A) @context Testing!")
    #   task.context
    #   # => ["@context"]
    attr_reader :contexts

    # Returns an array of all the +project annotations.
    #
    # Example:
    #
    #   task = Todo:Task.new("(A) +test Testing!")
    #   task.projects
    #   # => ["+test"]
    attr_reader :projects

    # Gets just the text content of the todo, without the priority, contexts
    # and projects annotations.
    #
    # Example:
    #
    #   task = Todo::Task.new("(A) @test Testing!")
    #   task.text
    #   # => "Testing!"
    def text
      @text ||= extract_item_text(raw)
    end

    # Deprecated. See: #created_on
    def date
      logger.warn("`Task#date` is deprecated, use `Task#created_on` instead.")

      @created_on
    end

    # Deprecated. See: #raw
    def orig
      logger.warn("`Task#orig` is deprecated, use `Task#raw` instead.")

      raw
    end

    # Returns the task's due date, if any.
    #
    # Example:
    #
    #   task = Todo::Task.new("(A) This is a task. due:2012-03-04")
    #   task.due_on
    #   # => <Date: 2012-03-04 (4911981/2,0,2299161)>
    #
    # Dates _must_ be in the YYYY-MM-DD format as specified in the todo.txt
    # format. Dates in any other format will be classed as malformed and this
    # attribute will be nil.
    def due_on
      begin
        Date.parse(tags[:due]) if tags[:due] =~ /(\d{4}-\d{2}-\d{2})/
      rescue ArgumentError
        return nil
      end
    end

    # Returns whether a task's due date is in the past.
    #
    # Example:
    #
    #   task = Todo::Task.new("This task is overdue! due:#{Date.today - 1}")
    #   task.overdue?
    #   # => true
    def overdue?
      !due_on.nil? && due_on < Date.today
    end

    # Returns true if the task is completed.
    #
    # Example:
    #
    #   task = Todo::Task.new("x 2012-12-08 Task.")
    #   task.done?
    #   # => true
    #
    #   task = Todo::Task.new("Task.")
    #   task.done?
    #   # => false
    def done?
      @is_completed
    end

    # Completes the task on the current date.
    #
    # Example:
    #
    #   task = Todo::Task.new("2012-12-08 Task.")
    #
    #   task.done?
    #   # => false
    #
    #   # Complete the task
    #   task.do!
    #
    #   task.done?
    #   # => true
    def do!
      @completed_on = Date.today
      @is_completed = true
      @priority = nil
    end

    # Marks the task as incomplete and resets its original priority.
    #
    # Example:
    #
    #   task = Todo::Task.new("x 2012-12-08 2012-03-04 Task.")
    #   task.done?
    #   # => true
    #
    #   # Undo the completed task
    #   task.undo!
    #
    #   task.done?
    #   # => false
    def undo!
      @completed_on = nil
      @is_completed = false
      @priority = extract_priority(raw)
    end

    # Increases the priority until A. If it's nil, it sets it to A.
    # @return [Char] the new priority of the task
    def priority_inc!
      if @priority.nil?
        @priority = 'A'
      elsif @priority.ord > 65
        @priority = (@priority.ord - 1).chr
      end
      @priority
    end

    # Decreases the priority until Z. if it's nil, it does nothing and
    # returns nil.
    # @return [Char] the new priority of the task
    def priority_dec!
      return if @priority.nil?
      @priority = @priority.next if @priority.ord < 90
      @priority
    end

    # Toggles the task from complete to incomplete or vice versa.
    #
    # Example:
    #
    #   task = Todo::Task.new("x 2012-12-08 Task.")
    #   task.done?
    #   # => true
    #
    #   # Toggle between complete and incomplete
    #   task.toggle!
    #
    #   task.done?
    #   # => false
    #
    #   task.toggle!
    #
    #   task.done?
    #   # => true
    def toggle!
      done? ? undo! : do!
    end

    # Compares the priorities of two tasks.
    #
    # Example:
    #
    #   task1 = Todo::Task.new("(A) Priority A.")
    #   task2 = Todo::Task.new("(B) Priority B.")
    #
    #   task1 > task2
    #   # => true
    #
    #   task1 == task2
    #   # => false
    #
    #   task2 > task1
    #   # => false
    def <=>(other)
      if priority.nil? && other.priority.nil?
        0
      elsif other.priority.nil?
        1
      elsif priority.nil?
        -1
      else
        other.priority <=> priority
      end
    end

    # Returns this task as a string.
    #
    # Example:
    #
    #   task = Todo::Task.new("(A) 2012-12-08 Task")
    #   task.to_s
    #   # => "(A) 2012-12-08 Task"
    def to_s
      [
        print_done_marker,
        print_priority,
        created_on.to_s,
        text,
        print_contexts,
        print_projects,
        print_tags
      ].reject { |item| !item || item.nil? || item.empty? }.join(' ')
    end

    private

    def print_done_marker
      return unless done?

      if completed_on.nil?
        COMPLETED_FLAG
      else
        "#{COMPLETED_FLAG} #{completed_on}"
      end
    end

    def print_priority
      return unless priority

      "(#{priority})"
    end

    def print_contexts
      contexts.join(' ')
    end

    def print_projects
      projects.join(' ')
    end

    def print_tags
      tags.map { |tag, val| "#{tag}:#{val}" }.join(' ')
    end
  end
end
