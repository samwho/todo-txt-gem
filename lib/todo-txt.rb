lib = File.dirname(__FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'logger'
require 'todo-txt/logger'
require 'todo-txt/syntax'
require 'todo-txt/list'
require 'todo-txt/task'
