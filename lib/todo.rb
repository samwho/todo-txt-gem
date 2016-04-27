require 'logger'
require 'todo/logger'
require 'todo/options'
require 'todo/syntax'
require 'todo/list'
require 'todo/task'
require 'todo/file'

# Allows for easy management of task lists and tasks in the todo.txt format.
module Todo
  # Provides global options for customizing todo list behaviour.
  class << self
    attr_accessor :options_instance
  end

  # Global access to custom options.
  #
  # Example:
  #
  #   if Todo.options.require_completed_on
  #     # Do something
  #   end
  def self.options
    self.options_instance ||= Options.new
  end

  # Customize global list behaviour.
  #
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
