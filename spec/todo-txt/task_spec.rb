require 'spec_helper'

describe Todo::Task do
  describe "Descriptions:" do
    it 'should convert to a string' do
      task = Todo::Task.new "(A) 2012-12-08 My task @test +test2"
      expect(task.to_s).to eq("(A) 2012-12-08 My task @test +test2")
    end

    it 'should keep track of the original string after changing the task' do
      task = Todo::Task.new "(A) 2012-12-08 My task @test +test2"
      Timecop.freeze(2013, 12, 8) do
        task.do!
        expect(task.orig).to eq("(A) 2012-12-08 My task @test +test2")
      end
    end

    it 'should be modifiable' do
      task = Todo::Task.new "2012-12-08 My task @test +test2"
      task.projects.clear
      task.contexts << ["@test3"]
      Timecop.freeze(2013, 12, 8) do
        task.do!
        expect(task.to_s).to eq("x 2013-12-08 2012-12-08 My task @test @test3")
      end
    end

    it 'should be able to get just the text, no due date etc.' do
      task = Todo::Task.new "x 2012-09-11 (B) 2012-03-04 This is a sweet task. @context due:2012-01-01 +project"
      expect(task.text).to eq("This is a sweet task.")
    end

    it 'should retain the original task creation string' do
      task = Todo::Task.new "(A) This is an awesome task, yo. +winning"
      expect(task.orig).to eq("(A) This is an awesome task, yo. +winning")
    end

    it 'should be able to get just the text, no contexts etc.' do
      task = Todo::Task.new "x 2012-09-11 (B) 2012-03-04 This is a sweet task. @context +project"
      expect(task.text).to eq("This is a sweet task.")
    end
  end

  describe "Priorities:" do
    it 'should recognise priorities' do
      task = Todo::Task.new "(A) Hello world!"
      expect(task.priority).to eq("A")
    end

    it 'should only recognise priorities at the start of a task' do
      task = Todo::Task.new "Hello, world! (A)"
      expect(task.priority).to eq(nil)
    end

    it 'should recognize priorities around dates' do
      task = Todo::Task.new "x 2012-09-11 (B) 2012-03-04 This is a sweet task. @context +project"
      expect(task.priority).to eq("B")
    end

    it 'should remove the priority when calling Task#do!' do
      task = Todo::Task.new "(A) Task"
      task.do!
      expect(task.priority).to be_nil
    end

    it 'should reset to the original priority when calling Task#undo!' do
      task = Todo::Task.new "(A) Task"
      task.do!
      task.undo!
      expect(task.priority).to eq("A")
    end
  end

  describe "Completion:" do
    it 'should be not done with missing date' do
      task = Todo::Task.new "x This is not done"
      expect(task.done?).to be false
    end

    it 'should be not done with malformed date' do
      task = Todo::Task.new "x 01-01-2013 This is not done"
      expect(task.done?).to be false
      expect(task.completed_on).to be nil
    end

    it 'should be not done with an invalid date' do
      task = Todo::Task.new "x 2013-02-31 This is not done"
      expect(task.done?).to be false
      expect(task.completed_on).to be nil
    end

    it 'should be done on 2013-04-22' do
      task = Todo::Task.new "x 2013-04-22 This is really done"
      expect(task.done?).to be true
      expect(task.completed_on).to eq(Date.parse('22th April 2013'))
    end

    it 'should be able to recognise completed tasks' do
      task = Todo::Task.new "x 2012-12-08 This is done!"
      expect(task.done?).to be true
    end

    it 'should not recognize incomplete tasks as done' do
      task = Todo::Task.new "2012-12-08 This ain't done!"
      expect(task.done?).to be false
    end

    it 'should be completable' do
      task = Todo::Task.new "2012-12-08 This ain't done!"
      task.do!
      expect(task.done?).to be true
    end

    it 'should be marked as incomplete' do
      task = Todo::Task.new "x 2012-12-08 This is done!"
      task.undo!
      expect(task.done?).to be false
    end

    it 'should be marked as incomplete without any date' do
      task = Todo::Task.new "x 2012-12-08 This is done!"
      task.undo!
      expect(task.completed_on).to be_nil
      expect(task.created_on).to be_nil
    end

    it 'should be toggable' do
      task = Todo::Task.new "2012-12-08 This ain't done!"
      task.toggle!
      expect(task.done?).to be true
      task.toggle!
      expect(task.done?).to be false
    end
  end

  describe "Contexts:" do
    it 'should recognise contexts' do
      task = Todo::Task.new "Hello, world! @test"
      expect(task.contexts).to eq(["@test"])
    end

    it 'should recognise multiple contexts' do
      task = Todo::Task.new "Hello, world! @test @test2"
      expect(task.contexts).to eq(["@test", "@test2"])
    end

    it 'should recognise contexts with dashes and underscores' do
      task = Todo::Task.new "Hello, world! @test-me @test2_me"
      expect(task.contexts).to eq(["@test-me", "@test2_me"])
    end
  end

  describe "Projects:" do
    it 'should recognise projects' do
      task = Todo::Task.new "Hello, world! +test"
      expect(task.projects).to eq(["+test"])
    end

    it 'should recognise multiple projects' do
      task = Todo::Task.new "Hello, world! +test +test2"
      expect(task.projects).to eq(["+test", "+test2"])
    end

    it 'should recognise projects with dashes and underscores' do
      task = Todo::Task.new "Hello, world! +test-me +test2_me"
      expect(task.projects).to eq(["+test-me", "+test2_me"])
    end
  end

  describe "Creation dates:" do
    it 'should be able to recognise creation dates' do
      task = Todo::Task.new "(C) 2012-03-04 This has a date!"
      expect(task.created_on).to eq(Date.parse("4th March 2012"))
    end

    it 'should be able to recognise creation dates without priority' do
      task = Todo::Task.new "2012-03-04 This has a date!"
      expect(task.created_on).to eq(Date.parse("4th March 2012"))
    end

    it 'should return nil if no creation date is present' do
      task = Todo::Task.new "No date!"
      expect(task.created_on).to be_nil
    end

    it 'should not recognise malformed dates' do
      task = Todo::Task.new "03-04-2012 This has a malformed date!"
      expect(task.created_on).to be_nil
    end

    it 'should be able to tell if the task is overdue' do
      task = Todo::Task.new((Date.today - 1).to_s + " This task is overdue!")
      expect(task.overdue?).to be false
    end

    it 'should return false on overdue? if there is no creation date' do
      task = Todo::Task.new "No date!"
      expect(task.overdue?).to be false
    end

    it 'should return nil on ridiculous date data' do
      task = Todo::Task.new "2012-56-99 This has a malformed date!"
      expect(task.created_on).to be_nil
    end
  end

  describe "Completion dates:" do
    it 'should be able to recognise completion dates' do
      task = Todo::Task.new "x 2012-12-08 This is done!"
      expect(task.completed_on).to eq(Date.parse("8th December 2012"))
    end

    it 'should set the current completion dates when calling Task#do!' do
      task = Todo::Task.new "2012-12-08 Task"
      Timecop.freeze(2013, 12, 8) do
        task.do!
        expect(task.completed_on).to eq(Date.parse("8th December 2013"))
      end
    end
  end

  describe "Due dates:" do
    it 'should have a due date' do
      task = Todo::Task.new '(A) this task has due date due:2013-12-22'
      expect(task.due_on).not_to be_nil
    end

    it 'should due on 2013-12-22' do
      task = Todo::Task.new '(A) this task has due date due:2013-12-22'
      expect(task.due_on).to eq(Date.parse('22th December 2013'))
    end

    it 'should not be overdue on 2013-12-01' do
      task = Todo::Task.new '(A) this task has due date due:2013-12-22'
      Timecop.freeze(2013, 12, 01) do
        expect(task.overdue?).to be false
      end
    end

    it 'should be overdue on 2013-12-23' do
      task = Todo::Task.new '(A) this task has due date due:2013-12-22'
      Timecop.freeze(2013, 12, 23) do
        expect(task.overdue?).to be true
      end
    end

    it 'should convert to a string with due date' do
      task = Todo::Task.new "x 2012-09-11 (B) 2012-03-04 This is a sweet task. @context due:2012-01-01 +project"
      expect(task.to_s).to eq("x 2012-09-11 (B) 2012-03-04 This is a sweet task. @context +project due:2012-01-01")
    end

    it 'should have no due date with malformed date' do
      task = Todo::Task.new "x 2012-09-11 (B) 2012-03-04 This is a sweet task. @context due:01-01-2012 +project"
      expect(task.due_on).to be_nil
    end

    it 'should have no due date with invalid date' do
      task = Todo::Task.new "x 2012-09-11 (B) 2012-03-04 This is a sweet task. @context due:2012-02-31 +project"
      expect(task.due_on).to be_nil
    end

    it 'should recognize DUE:2013-12-22 (case insensitive)' do
      task = Todo::Task.new '(A) this task has due date DUE:2013-12-22'
      expect(task.due_on).to eq(Date.parse('22th December 2013'))
    end

    it 'should reset to the original due date when calling Task#undo!' do
      task = Todo::Task.new "2012-12-08 Task"
      Timecop.freeze(2013, 12, 8) do
        task.do!
        task.undo!
        expect(task.created_on).to eq(Date.parse("8th December 2012"))
      end
    end

    it 'should manage dates when calling Task#toggle!' do
      task = Todo::Task.new "2012-12-08 This ain't done!"
      Timecop.freeze(2013, 12, 8) do
        task.toggle!
        expect(task.completed_on).to eq(Date.parse("8th December 2013"))
        expect(task.created_on).to eq(Date.parse("8th December 2012"))
        task.toggle!
        expect(task.created_on).to eq(Date.parse("8th December 2012"))
        expect(task.completed_on).to be_nil
      end
    end
  end

  describe "Comparisons:" do
    it 'should be comparable' do
      task1 = Todo::Task.new "(A) Top priority, y'all!"
      task2 = Todo::Task.new "(B) Not quite so high."

      assertion = task1 > task2
      expect(assertion).to eq(true)
    end

    it 'should be comparable to task without priority' do
      task1 = Todo::Task.new "Top priority, y'all!"
      task2 = Todo::Task.new "(B) Not quite so high."

      assertion = task1 < task2
      expect(assertion).to eq(true)
    end

    it 'should be able to compare two tasks without priority' do
      task1 = Todo::Task.new "Top priority, y'all!"
      task2 = Todo::Task.new "Not quite so high."

      assertion = task1 == task2
      expect(assertion).to eq(true)
    end
  end

  describe "Logging:" do
    it 'should have a logger' do
      task = Todo::Task.new "x 2012-09-11 (B) 2012-03-04 This is a sweet task. @context due:2012-02-31 +project"
      expect(task.logger).not_to be nil
    end

    it 'should call @logger.warn if #date called as deprecated method' do
      logger = double(Logger)
      Todo::Logger.logger = logger

      task = Todo::Task.new "x 2012-09-11 (B) 2012-03-04 This is a sweet task. @context due:2012-02-31 +project"
      error_message = 'Task#date is deprecated, use created_on instead.'

      expect(logger).to receive(:warn).with(error_message)
      task.date
    end
  end
end
