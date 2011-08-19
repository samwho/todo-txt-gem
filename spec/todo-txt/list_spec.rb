require_relative '../spec_helper'

describe Todo::List do
  # A helper method to grab the test data list.
  def list
    Todo::List.new(File.dirname(__FILE__) + '/../data/todo.txt')
  end

  it 'should grab a list of Todo::Tasks' do
    list.each do |task|
      task.class.should == Todo::Task
    end

    # This is a little bit fragile but it helps me sleep at night.
    list[0].priority.should == "A"
  end

  it 'should be able to filter by priority' do
    list.by_priority("A").each do |task|
      task.priority.should == "A"
    end

    # Make sure some data was actually checked
    list.by_priority("A").length.should be > 0
  end

  it 'should be able to filter by context' do
    list.by_context("@context").each do |task|
      task.contexts.should include "@context"
    end

    # Make sure some data was actually checked
    list.by_context("@context").length.should be > 0
  end

  it 'should be able to filter by project' do
    list.by_project("+project").each do |task|
      task.projects.should include "+project"
    end

    # Make sure some data was actually checked
    list.by_project("+project").length.should be > 0
  end

  it 'should be able to filter by project, context and priority' do
    filtered = list.by_project("+project").
                    by_context("@context").
                    by_priority("C")

    filtered.each do |task|
      task.projects.should include "+project"
      task.contexts.should include "@context"
      task.priority.should == "C"
    end

    # Make sure some data was actually checked
    filtered.length.should be > 0
  end

  it 'should be sortable' do
    list.sort.each_cons(2) do |task_a, task_b|
      task_a.should be <= task_b
    end

    # Make sure some data was actually checked
    list.sort.length.should be > 0

    # Class should still be Todo::List
    list.sort.class.should == Todo::List
  end
end
