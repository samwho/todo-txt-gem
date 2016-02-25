require File.join(File.dirname(__FILE__), "../spec_helper.rb")
require 'date'
require 'timecop'

describe Todo::Task do
  describe "Descriptions:" do
    it 'should convert to a string' do
      task = Todo::Task.new "(A) 2012-12-08 My task @test +test2"
      task.to_s.should == "(A) 2012-12-08 My task @test +test2"
    end
  
    it 'should keep track of the original string after changing the task' do
      task = Todo::Task.new "(A) 2012-12-08 My task @test +test2"
      Timecop.freeze(2013, 12, 8) do
        task.do!
        task.orig.should == "(A) 2012-12-08 My task @test +test2"
      end
    end
  
    it 'should be modifiable' do
      task = Todo::Task.new "2012-12-08 My task @test +test2"
      task.projects.clear
      task.contexts << ["@test3"]
      Timecop.freeze(2013, 12, 8) do
        task.do!
        task.to_s.should == "x 2013-12-08 2012-12-08 My task @test @test3"
      end
    end

    it 'should be able to get just the text, no due date etc.' do
      task = Todo::Task.new "x 2012-09-11 (B) 2012-03-04 This is a sweet task. @context due:2012-01-01 +project"
      task.text.should == "This is a sweet task."
    end

    it 'should retain the original task creation string' do
      task = Todo::Task.new "(A) This is an awesome task, yo. +winning"
      task.orig.should == "(A) This is an awesome task, yo. +winning"
    end

    it 'should be able to get just the text, no contexts etc.' do
      task = Todo::Task.new "x 2012-09-11 (B) 2012-03-04 This is a sweet task. @context +project"
      task.text.should == "This is a sweet task."
    end
  end
  
  describe "Priorities:" do
    it 'should recognise priorities' do
      task = Todo::Task.new "(A) Hello world!"
      task.priority.should == "A"
    end

    it 'should only recognise priorities at the start of a task' do
      task = Todo::Task.new "Hello, world! (A)"
      task.priority.should == nil
    end

    it 'should recognize priorities around dates' do
      task = Todo::Task.new "x 2012-09-11 (B) 2012-03-04 This is a sweet task. @context +project"
      task.priority.should == "B"
    end

    it 'should remove the priority when calling Task#do!' do
      task = Todo::Task.new "(A) Task"
      task.do!
      task.priority.should be_nil
    end

    it 'should reset to the original priority when calling Task#undo!' do
      task = Todo::Task.new "(A) Task"
      task.do!
      task.undo!
      task.priority.should == "A"
    end
  end

  describe "Completion:" do
    it 'should be not done with missing date' do
      task = Todo::Task.new "x This is not done"
      task.done?.should be false
    end

    it 'should be not done with malformed date' do
      task = Todo::Task.new "x 01-01-2013 This is not done"
      task.done?.should be false
      task.completed_on.should be nil
    end

    it 'should be not done with an invalid date' do
      task = Todo::Task.new "x 2013-02-31 This is not done"
      task.done?.should be false
      task.completed_on.should be nil
    end

    it 'should be done on 2013-04-22' do
      task = Todo::Task.new "x 2013-04-22 This is really done"
      task.done?.should be true
      task.completed_on.should == Date.parse('22th April 2013')
    end
    
    it 'should be able to recognise completed tasks' do
      task = Todo::Task.new "x 2012-12-08 This is done!"
      task.done?.should be_true
    end

    it 'should not recognize incomplete tasks as done' do
      task = Todo::Task.new "2012-12-08 This ain't done!"
      task.done?.should be_false
    end

    it 'should be completable' do
      task = Todo::Task.new "2012-12-08 This ain't done!"
      task.do!
      task.done?.should be_true
    end

    it 'should be marked as incomplete' do
      task = Todo::Task.new "x 2012-12-08 This is done!"
      task.undo!
      task.done?.should be_false
    end

    it 'should be marked as incomplete without any date' do
      task = Todo::Task.new "x 2012-12-08 This is done!"
      task.undo!
      task.completed_on.should be_nil
      task.created_on.should be_nil
    end

    it 'should be toggable' do
      task = Todo::Task.new "2012-12-08 This ain't done!"
      task.toggle!
      task.done?.should be_true
      task.toggle!
      task.done?.should be_false
    end
  end
  
  describe "Contexts:" do
    it 'should recognise contexts' do
      task = Todo::Task.new "Hello, world! @test"
      task.contexts.should == ["@test"]
    end

    it 'should recognise multiple contexts' do
      task = Todo::Task.new "Hello, world! @test @test2"
      task.contexts.should == ["@test", "@test2"]
    end

    it 'should recognise contexts with dashes and underscores' do
      task = Todo::Task.new "Hello, world! @test-me @test2_me"
      task.contexts.should == ["@test-me", "@test2_me"]
    end
  end
  
  describe "Projects:" do
    it 'should recognise projects' do
      task = Todo::Task.new "Hello, world! +test"
      task.projects.should == ["+test"]
    end

    it 'should recognise multiple projects' do
      task = Todo::Task.new "Hello, world! +test +test2"
      task.projects.should == ["+test", "+test2"]
    end

    it 'should recognise projects with dashes and underscores' do
      task = Todo::Task.new "Hello, world! +test-me +test2_me"
      task.projects.should == ["+test-me", "+test2_me"]
    end
  end
  
  describe "Creation dates:" do
    it 'should be able to recognise creation dates' do
      task = Todo::Task.new "(C) 2012-03-04 This has a date!"
      task.created_on.should == Date.parse("4th March 2012")
    end

    it 'should be able to recognise creation dates without priority' do
      task = Todo::Task.new "2012-03-04 This has a date!"
      task.created_on.should == Date.parse("4th March 2012")
    end

    it 'should return nil if no creation date is present' do
      task = Todo::Task.new "No date!"
      task.created_on.should be_nil
    end

    it 'should not recognise malformed dates' do
      task = Todo::Task.new "03-04-2012 This has a malformed date!"
      task.created_on.should be_nil
    end
  
    it 'should be able to tell if the task is overdue' do
      task = Todo::Task.new((Date.today - 1).to_s + " This task is overdue!")
      task.overdue?.should be_false
    end

    it 'should return false on overdue? if there is no creation date' do
      task = Todo::Task.new "No date!"
      task.overdue?.should be_false
    end

    it 'should return nil on ridiculous date data' do
      task = Todo::Task.new "2012-56-99 This has a malformed date!"
      task.created_on.should be_nil
    end
  end
  
  describe "Completion dates:" do
    it 'should be able to recognise completion dates' do
      task = Todo::Task.new "x 2012-12-08 This is done!"
      task.completed_on.should == Date.parse("8th December 2012")
    end

    it 'should set the current completion dates when calling Task#do!' do
      task = Todo::Task.new "2012-12-08 Task"
      Timecop.freeze(2013, 12, 8) do
        task.do!
        task.completed_on.should == Date.parse("8th December 2013")
      end
    end
  end

  describe "Due dates:" do
    its 'should have a due date' do
      task = Todo::Task.new '(A) this task has due date due:2013-12-22'
      task.due_on.should_not be_nil
    end

    it 'should due on 2013-12-22' do
      task = Todo::Task.new '(A) this task has due date due:2013-12-22'
      task.due_on.should == Date.parse('22th December 2013')
    end

    it 'should not be overdue on 2013-12-01' do
      task = Todo::Task.new '(A) this task has due date due:2013-12-22'
      Timecop.freeze(2013, 12, 01) do
        task.overdue?.should be_false
      end
    end

    it 'should be overdue on 2013-12-23' do
      task = Todo::Task.new '(A) this task has due date due:2013-12-22'
      Timecop.freeze(2013, 12, 23) do
        task.overdue?.should be_true
      end
    end

    it 'should convert to a string with due date' do
      task = Todo::Task.new "x 2012-09-11 (B) 2012-03-04 This is a sweet task. @context due:2012-01-01 +project"
      task.to_s.should == "x 2012-09-11 (B) 2012-03-04 This is a sweet task. @context +project due:2012-01-01"
    end

    it 'should have no due date with malformed date' do
      task = Todo::Task.new "x 2012-09-11 (B) 2012-03-04 This is a sweet task. @context due:01-01-2012 +project"
      task.due_on.should be_nil
    end

    it 'should have no due date with invalid date' do
      task = Todo::Task.new "x 2012-09-11 (B) 2012-03-04 This is a sweet task. @context due:2012-02-31 +project"
      task.due_on.should be_nil
    end

    it 'should recognize DUE:2013-12-22 (case insensitive)' do
      task = Todo::Task.new '(A) this task has due date DUE:2013-12-22'
      task.due_on.should == Date.parse('22th December 2013')
    end
    
    it 'should reset to the original due date when calling Task#undo!' do
      task = Todo::Task.new "2012-12-08 Task"
      Timecop.freeze(2013, 12, 8) do
        task.do!
        task.undo!
        task.created_on.should == Date.parse("8th December 2012")
      end
    end

    it 'should manage dates when calling Task#toggle!' do
      task = Todo::Task.new "2012-12-08 This ain't done!"
      Timecop.freeze(2013, 12, 8) do
        task.toggle!
        task.completed_on.should == Date.parse("8th December 2013")
        task.created_on.should == Date.parse("8th December 2012")
        task.toggle!
        task.created_on.should == Date.parse("8th December 2012")
        task.completed_on.should be_nil
      end
    end
  end

  describe "Comparisons:" do
    it 'should be comparable' do
      task1 = Todo::Task.new "(A) Top priority, y'all!"
      task2 = Todo::Task.new "(B) Not quite so high."

      assertion = task1 > task2
      assertion.should == true
    end

    it 'should be comparable to task without priority' do
      task1 = Todo::Task.new "Top priority, y'all!"
      task2 = Todo::Task.new "(B) Not quite so high."

      assertion = task1 < task2
      assertion.should == true
    end

    it 'should be able to compare two tasks without priority' do
      task1 = Todo::Task.new "Top priority, y'all!"
      task2 = Todo::Task.new "Not quite so high."

      assertion = task1 == task2
      assertion.should == true
    end
  end
  
  describe "Logging:" do
    it 'should have a logger' do
      task = Todo::Task.new "x 2012-09-11 (B) 2012-03-04 This is a sweet task. @context due:2012-02-31 +project"
      task.logger.should_not be nil
    end

    it 'should call @logger.warn if #date called as deprecated method' do
      logger = double(Logger)
      Todo::Logger.logger = logger

      task = Todo::Task.new "x 2012-09-11 (B) 2012-03-04 This is a sweet task. @context due:2012-02-31 +project"
      error_message = 'Task#date is deprecated, use created_on instead.'

      logger.should_receive(:warn).with(error_message)
      task.date
    end
  end
end
