require 'spec_helper'

describe Todo::Options do
  it 'should be available by default in the top-level module' do
    expect(Todo.options).to be_a Todo::Options
  end

  it 'should provide require_completed_on as true by default' do
    expect(Todo.options.require_completed_on).to be true
  end

  it 'should provide maintain_field_order as false by default' do
    expect(Todo.options.maintain_field_order).to be false
  end

  it 'should support customization' do
    Todo.customize do |options|
      options.require_completed_on = false
    end

    expect(Todo.options.require_completed_on).to be false
  end

  after(:all) do
    Todo.options.reset
  end
end
