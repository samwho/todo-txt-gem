require 'spec_helper'

describe Todo::Syntax do
  include Todo::Syntax

  describe '#get_context_tags' do
    specify 'empty task' do
      expect(get_context_tags('')).to eq([])
    end

    specify 'task without context' do
      expect(get_context_tags('something to do')).to eq([])
    end

    specify 'task with single context' do
      expect(get_context_tags('something to do @work')).to eq(['@work'])
    end

    specify 'task with multiple contexts' do
      expect(get_context_tags('something to do @work @play')).to eq(['@work', '@play'])
    end
  end

  describe '#get_project_tags' do
    specify 'empty task' do
      expect(get_project_tags('')).to eq([])
    end

    specify 'task without project' do
      expect(get_project_tags('something to do')).to eq([])
    end

    specify 'task with single project' do
      expect(get_project_tags('something to do +report')).to eq(['+report'])
    end

    specify 'task with multiple projects' do
      expect(get_project_tags('something to do +report +analysis')).to eq(['+report', '+analysis'])
    end
  end

  describe '#orig_priority' do
    specify 'empty task' do
      expect(orig_priority('')).to be nil
    end

    specify 'task without priority' do
      expect(orig_priority('something to do')).to be nil
    end

    specify 'task with priority A' do
      expect(orig_priority('(A) something to do')).to eq('A')
    end

    specify 'task with priority B' do
      expect(orig_priority('(B) something to do')).to eq('B')
    end
  end

  describe '#orig_created_on' do
    specify 'empty task' do
      expect(orig_created_on('')).to be nil
    end

    specify 'task without date' do
      expect(orig_created_on('something to do')).to be nil
    end

    specify 'task with created date' do
      expect(orig_created_on('2016-03-29 something to do')).to eq(Date.new(2016, 03, 29))
    end

    specify 'prioritised task with created date' do
      expect(orig_created_on('(A) 2016-03-29 something to do')).to eq(Date.new(2016, 03, 29))
    end

    specify 'date included in task text' do
      expect(orig_created_on('(A) something to do on 2016-03-29')).to be nil
    end
  end

  describe '#get_completed_date' do
    specify 'empty task' do
      expect(get_completed_date('')).to be nil
    end

    specify 'uncompleted task' do
      expect(get_completed_date('2016-03-29 something to do')).to be nil
    end

    specify 'completed task without date' do
      expect(get_completed_date('2016-03-29 something to do')).to be nil
    end

    specify 'completed task without date' do
      expect(get_completed_date('2016-03-29 something to do')).to be nil
    end
  end

  describe '#get_due_on_date' do
    specify 'empty task' do
      expect(get_due_on_date('')).to be nil
    end

    specify 'task without due date' do
      expect(get_due_on_date('something to do')).to be nil
    end

    specify 'task with due date' do
      expect(get_due_on_date('something to do due:2016-03-30')).to eq(Date.new(2016, 03, 30))
    end
  end

  describe '#get_item_text' do
    specify 'empty task' do
      expect(get_item_text('')).to eq('')
    end

    specify 'task without markup' do
      expect(get_item_text('something to do')).to eq('something to do')
    end

    specify 'task with date, priority, projects and context' do
      expect(get_item_text('(A) 2016-03-29 something to do +experiment @work')).to eq('something to do')
    end

    specify 'completed task with projects and context' do
      expect(get_item_text('x 2016-03-30 2016-03-29 something to do +experiment @work')).to eq('something to do')
    end
  end
end
