require_relative '../spec_helper'

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
    task = Todo::Task.new "(B) This is a sweet task. @context +project"
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
end
