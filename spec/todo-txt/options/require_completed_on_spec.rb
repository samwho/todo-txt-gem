require 'spec_helper'

describe '#require_completed_on' do
  context 'set to true' do
    it 'should treat tasks without the done flag as not done' do
      task = Todo::Task.new('this task is treated as incomplete')
      expect(task.done?).to be false
    end

    it 'should treat tasks with a the done flag and no date as not done' do
      task = Todo::Task.new('x this task is treated as incomplete')
      expect(task.done?).to be false
    end

    it 'should treat tasks with a the done flag and a completion date as done' do
      task = Todo::Task.new('x 2016-04-08 this task is treated as complete')
      expect(task.done?).to be true
    end
  end

  context 'set to false' do
    before(:all) do
      Todo.customize do |options|
        options.require_completed_on = false
      end
    end

    it 'should treat tasks without the done flag as not done' do
      task = Todo::Task.new('this task is treated as incomplete')
      expect(task.done?).to be false
    end

    it 'should treat tasks with the done flag as done' do
      task = Todo::Task.new('x this task is treated as complete')
      expect(task.done?).to be true
    end

    after(:all) do
      Todo.options.reset
    end
  end
end
