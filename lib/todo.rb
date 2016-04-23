require 'logger'
require 'todo-txt/logger'
require 'todo-txt/options'
require 'todo-txt/syntax'
require 'todo-txt/list'
require 'todo-txt/task'

# Allows for easy management of task lists and tasks in the todo.txt format.
module Todo
  # Provides global options for customizing todo list behaviour.
  class << self
    attr_accessor :options_instance
  end

  def self.options
    self.options_instance ||= Options.new
  end

  # Example:
  #
  #   Todo.customize do |opts|
  #     opts.require_completed_on = false
  #   end
  def self.customize
    self.options_instance ||= Options.new
    yield(options_instance)
  end
end
