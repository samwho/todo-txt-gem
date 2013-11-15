# Todo.txt

[![Development Build Status](https://secure.travis-ci.org/samwho/todo-txt-gem.png?branch=develop)](http://travis-ci.org/samwho/todo-txt-gem)
[![Master Build Status](https://secure.travis-ci.org/samwho/todo-txt-gem.png?branch=master)](http://travis-ci.org/samwho/todo-txt-gem)

This is a Ruby client library for Gina Trapani's
[todo.txt](https://github.com/ginatrapani/todo.txt-cli/). It allows for easy
parsing of task lists and tasks in the todo.txt format.

Find the project on GitHub:
[http://github.com/samwho/todo-txt-gem](http://github.com/samwho/todo-txt-gem).

# Installation

Installation is very simple. The project is packaged as a Ruby gem and can be
installed by running:

    gem install todo-txt

# Usage

## Todo::List

A `Todo::List` object encapsulates your todo.txt file. You initialise it by
passing the path to your todo.txt to the constructor:

``` ruby
require 'todo-txt'

list = Todo::List.new "path/to/todo.txt"
```

`Todo::List` subclasses `Array` so it has all of the standard methods that are
available on an array. It is, basically, an array of `Todo::Task` items.

### Filtering

You can filter your todo list by priority, project, context or a combination of
all three with ease.

``` ruby
require 'todo-txt'

list = Todo::List.new "path/to/todo.txt"

list.by_priority "A"
# => Contains a Todo::List object with only priority A tasks.

list.by_context "@code"
# => Returns a new Todo::List with only tasks that have a @code context.

list.by_project "+manhatten"
# => Returns a new Todo::List with only tasks that are part of the
      +manhatten project (see what I did there?)

# And you can combine these, like so
list.by_project("+manhatten").by_priority("B")
```

## Todo::Task

A `Todo::Task` object can be created from a standard task string if you don't
want to use the `Todo::List` approach (though using `Todo::List` is
recommended).

``` ruby
require 'todo-txt'

task = Todo::Task.new "(A) This task is top priority! +project @context"

task.priority
# => "A"

task.contexts
# => ["@context"]

task.projects
# => ["+project"]

task.text
# => "This task is top priority!"

task.orig
# => "(A) This task is top priority! +project @context"
```

### Comparable

The `Todo::Task` object includes the `Comparable` mixin. It compares with other
tasks and sorts by priority in descending order.

``` ruby
task1 = Todo::Task.new "(A) Priority A."
task2 = Todo::Task.new "(B) Priority B."

task1 > task2
# => true

task1 == task2
# => false

task2 > task1
# => false
```

Tasks without a priority will always be less than a task with a priority.

# Requirements

The todo-txt gem requires Ruby 1.9.2 or higher. It doesn't currently run on
1.8.7.
