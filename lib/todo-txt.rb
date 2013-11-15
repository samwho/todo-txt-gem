require 'logger'

lib = File.dirname(__FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'todo-txt/logger'
require 'todo-txt/list'
require 'todo-txt/task'
