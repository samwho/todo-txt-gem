require 'spec_helper'

describe Todo::List do
  let(:path) { File.dirname(__FILE__) + '/../data/todo.txt' }
  let(:mutable_path) { File.dirname(__FILE__) + '/../data/tasks.txt' }
  let(:list) { Todo::List.new(path) }

  context 'create with an array' do
    it 'successfully creates an object' do
      array = Array.new
      array.push "(A) A string task!"
      array.push Todo::Task.new("(A) An actual task!")
      expect(Todo::List.new array).not_to eq(nil)
    end

    it 'does not have a path' do
      array = Array.new
      array.push "(A) A string task!"
      array.push Todo::Task.new("(A) An actual task!")
      expect(Todo::List.new(array).path).to eq(nil)
    end
  end

  context 'create and save from file' do
    it 'successfully writes back changes' do
      backup = Todo::List.new(mutable_path)

      tasks = Todo::List.new(mutable_path)
      tasks.each(&:do!)
      tasks.save!

      result = Todo::List.new(mutable_path)

      expect(result.by_done.count).to eq(3)

      backup.save!
    end
  end

  it 'accepts a mix of tasks and strings' do
    l = Todo::List.new([
      "A task!",
      Todo::Task.new("Another task!"),
    ])

    expect(l.length).to eq(2)
  end

  it 'has the correct path' do
    expect(list.path).to eq(path)
  end

  it 'creates a list of Todo::Tasks' do
    list.each do |task|
      expect(task.class).to eq(Todo::Task)
    end
  end

  it 'it retrieves the list in the expected order' do
    expect(list.first.text).to eq('Crack the Da Vinci Code.')
    expect(list.last.text).to eq(
      'This task is completed and has created and completion dates')
  end

  it 'it retrieves the expected number of items' do
    expect(list.count).to eq(11)
  end

  it 'should be able to filter by priority' do
    # Make sure some data was actually checked
    priority_list = list.by_priority('A')
    expect(priority_list.length).to be > 0

    priority_list.each do |task|
      expect(task.priority).to eq('A')
    end
  end

  it 'should be able to filter by context' do
    # Make sure some data was actually checked
    context_list = list.by_context('@context')
    expect(context_list.length).to be > 0

    context_list.each do |task|
      expect(task.contexts).to include '@context'
    end
  end

  it 'should be able to filter by project' do
    # Make sure some data was actually checked
    project_list = list.by_project('+project')
    expect(project_list.length).to be > 0

    project_list.each do |task|
      expect(task.projects).to include '+project'
    end
  end

  it 'should be able to filter by project, context and priority' do
    filtered = list.by_project('+project').
                    by_context('@context').
                    by_priority('C')

    # Make sure some data was actually checked
    expect(filtered.length).to be > 0

    filtered.each do |task|
      expect(task.projects).to include '+project'
      expect(task.contexts).to include '@context'
      expect(task.priority).to eq('C')
    end
  end

  it 'filters by done' do
    done_list = list.by_done

    # Make sure some data was actually checked
    expect(done_list.length).to eq(2)

    list.by_done.each do |task|
      expect(task.text).to include 'This task is completed'
    end
  end

  it 'filters by not done' do
    not_done_list = list.by_not_done

    # Make sure some data was actually checked
    expect(not_done_list.length).to eq(9)

    not_done_list.each do |task|
      expect(task.text).not_to include 'This task is completed'
    end
  end

  it 'should be sortable' do
    list.sort.each_cons(2) do |task_a, task_b|
      expect(task_a).to be <= task_b
    end

    # Make sure some data was actually checked
    expect(list.sort.length).to be > 0
  end

  it 'returns a list on sort'
  # Class should still be Todo::List
  # This assertion currently fails. TODO.
  # expect(list.sort).to be_a Todo::List
end
