require_relative '../spec_helper'
require 'date'

describe Todo::Task do
  it 'should recognise priorities' do
    task = Todo::Task.new "(A) Hello world!"
    task.priority.should == "A"
  end

  it 'should only recognise priorities at the start of a task' do
    task = Todo::Task.new "Hello, world! (A)"
    task.priority.should == nil
  end

  it 'should recognise contexts' do
    task = Todo::Task.new "Hello, world! @test"
    task.contexts.should == ["@test"]
  end

  it 'should recognise multiple contexts' do
    task = Todo::Task.new "Hello, world! @test @test2"
    task.contexts.should == ["@test", "@test2"]
  end

  it 'should recognise projects' do
    task = Todo::Task.new "Hello, world! +test"
    task.projects.should == ["+test"]
  end

  it 'should recognise multiple projects' do
    task = Todo::Task.new "Hello, world! +test +test2"
    task.projects.should == ["+test", "+test2"]
  end

  it 'should retain the original task' do
    task = Todo::Task.new "(A) This is an awesome task, yo. +winning"
    task.orig.should == "(A) This is an awesome task, yo. +winning"
  end

  it 'should be able to get just the text, no contexts etc.' do
    task = Todo::Task.new "x (B) 2012-03-04 This is a sweet task. @context +project"
    task.text.should == "This is a sweet task."
  end

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

  it 'should be able to recognise dates' do
    task = Todo::Task.new "(C) 2012-03-04 This has a date!"
    task.date.should == Date.parse("4th March 2012")
  end

  it 'should be able to recognise dates without priority' do
    task = Todo::Task.new "2012-03-04 This has a date!"
    task.date.should == Date.parse("4th March 2012")
  end

  it 'should return nil if no date is present' do
    task = Todo::Task.new "No date!"
    task.date.should be_nil
  end

  it 'should not recognise malformed dates' do
    task = Todo::Task.new "03-04-2012 This has a malformed date!"
    task.date.should be_nil
  end

  it 'should be able to tell if the task is overdue' do
    task = Todo::Task.new((Date.today - 1).to_s + " This task is overdue!")
    task.overdue?.should be_true
  end

  it 'should return nil on overdue? if there is no date' do
    task = Todo::Task.new "No date!"
    task.overdue?.should be_nil
  end

  it 'should return nil on ridiculous date data' do
    task = Todo::Task.new "2012-56-99 This has a malformed date!"
    task.date.should be_nil
  end

  it 'should be able to recognise completed tasks' do
    task = Todo::Task.new "x 2012-12-08 This is done!"
    task.done?.should be_true
  end

  it 'should not recognize incomplete tasks as done' do
    task = Todo::Task.new "2012-12-08 This is ain't done!"
    task.done?.should be_false
  end

  it 'should be able to recognise completion dates' do
    task = Todo::Task.new "x 2012-12-08 This is done!"
    task.date.should == Date.parse("8th December 2012")
  end
end
