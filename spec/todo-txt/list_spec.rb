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
end
