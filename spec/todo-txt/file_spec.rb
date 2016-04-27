require 'spec_helper'

describe Todo::File do
  let(:path) { File.dirname(__FILE__) + '/../data/todo.txt' }

  context 'reading input' do
    it 'should raise a system error when file not found' do
      expect { Todo::File.open('not_found') }.to raise_error Errno::ENOENT
    end

    it 'should yield each task from block passed to open' do
      Todo::File.open(path) do |file|
        file.each do |task|
          expect(task).to be_a Todo::Task
        end
      end
    end

    it 'should return a file object when no block is passed to open' do
      file = Todo::File.open(path)
      expect(file).to be_a Todo::File
    end

    it 'should return an enumerator when no block is passed to each' do
      enumerator = Todo::File.open(path).each
      expect(enumerator).to be_a Enumerator
      expect(enumerator.next).to be_a Todo::Task
    end

    it 'should read a file into an array of tasks' do
      list = Todo::File.read(path)
      expect(list).to be_a Array
      expect(list.first).to be_a Todo::Task
    end
  end

  context 'writing' do
    let(:path) { File.dirname(__FILE__) + '/../data/test.txt' }

    it 'should write to a list file when initialized in writeable mode' do
      file = Todo::File.new(path, 'w')
      file.puts(Todo::Task.new('Task 1'))
      file.puts(Todo::Task.new('Task 2'))
      file.close

      target = File.open(path)
      expect(target.gets.rstrip).to eq("Task 1")
      expect(target.gets.rstrip).to eq("Task 2")
    end

    it 'should write to a list file when opened in writeable mode' do
      Todo::File.open(path, 'w') do |file|
        file.puts(Todo::Task.new('Task 1'))
        file.puts(Todo::Task.new('Task 2'))
      end

      target = File.open(path)
      expect(target.gets.rstrip).to eq("Task 1")
      expect(target.gets.rstrip).to eq("Task 2")
    end

    it 'should write each task in the list to a line in the file' do
      list = Todo::List.new([Todo::Task.new('Task 1'), Todo::Task.new('Task 2')])
      Todo::File.write(path, list)

      target = File.open(path)
      expect(target.gets.rstrip).to eq("Task 1")
      expect(target.gets.rstrip).to eq("Task 2")
    end

    after do
      File.delete(path)
    end
  end
end
