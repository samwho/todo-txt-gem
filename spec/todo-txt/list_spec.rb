require 'spec_helper'

describe Todo::List do
  let(:path) { File.dirname(__FILE__) + '/../data/todo.txt' }
  let(:list) { Todo::List.new(path) }

  it 'should have the correct path' do
    expect(list.path).to eq(path)
  end

  it 'should grab a list of Todo::Tasks' do
    list.each do |task|
      expect(task.class).to eq(Todo::Task)
    end

    # This is a little bit fragile but it helps me sleep at night.
    expect(list[0].priority).to eq("A")
  end

  it 'should be able to filter by priority' do
    list.by_priority("A").each do |task|
      expect(task.priority).to eq("A")
    end

    # Make sure some data was actually checked
    expect(list.by_priority("A").length).to be > 0
  end

  it 'should be able to filter by context' do
    list.by_context("@context").each do |task|
      expect(task.contexts).to include "@context"
    end

    # Make sure some data was actually checked
    expect(list.by_context("@context").length).to be > 0
  end

  it 'should be able to filter by project' do
    list.by_project("+project").each do |task|
      expect(task.projects).to include "+project"
    end

    # Make sure some data was actually checked
    expect(list.by_project("+project").length).to be > 0
  end

  it 'should be able to filter by project, context and priority' do
    filtered = list.by_project("+project").
                    by_context("@context").
                    by_priority("C")

    filtered.each do |task|
      expect(task.projects).to include "+project"
      expect(task.contexts).to include "@context"
      expect(task.priority).to eq("C")
    end

    # Make sure some data was actually checked
    expect(filtered.length).to be > 0
  end

  it 'should be able to filter by done' do
    list.by_done.each do |task|
      expect(task.text).to include 'This task is completed'
    end

    expect(list.by_done.length).to eq(2)
  end

  it 'should be able to filter by not done' do
    list.by_not_done.each do |task|
      expect(task.text).not_to include 'This task is completed'
    end

    expect(list.by_not_done.length).to eq(9)
  end

  it 'should be sortable' do
    list.sort.each_cons(2) do |task_a, task_b|
      expect(task_a).to be <= task_b
    end

    # Make sure some data was actually checked
    expect(list.sort.length).to be > 0

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

      expect(l.length).to eq(2)
    end
  end
end
