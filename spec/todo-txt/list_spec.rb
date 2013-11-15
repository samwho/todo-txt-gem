require File.join(File.dirname(__FILE__), "../spec_helper.rb")

describe Todo::List do
  let(:path) { File.dirname(__FILE__) + '/../data/todo.txt' }
  let(:list) { Todo::List.new(path) }

  it 'should have the correct path' do
    list.path.should == path
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
    # This assertion currently fails. TODO.
    # list.sort.should be_a Todo::List
  end

  describe 'manual list creation' do
    it 'should be possible with a mix of tasks and strings' do
      l = Todo::List.new([
        "A task!",
        Todo::Task.new("Another task!"),
      ])

      l.length.should == 2
    end
  end
end
