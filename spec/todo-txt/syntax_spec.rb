require 'spec_helper'

describe Todo::Syntax do
  include Todo::Syntax

  describe '#extract_contexts' do
    specify 'empty task' do
      expect(extract_contexts('')).to eq([])
    end

    specify 'task without context' do
      expect(extract_contexts('something to do')).to eq([])
    end

    specify 'task with single context' do
      expect(extract_contexts('something to do @work')).to eq(['@work'])
    end

    specify 'task with multiple contexts' do
      expect(extract_contexts('something to do @work @play')).to eq(['@work', '@play'])
    end
  end

  describe '#extract_projects' do
    specify 'empty task' do
      expect(extract_projects('')).to eq([])
    end

    specify 'task without project' do
      expect(extract_projects('something to do')).to eq([])
    end

    specify 'task with single project' do
      expect(extract_projects('something to do +report')).to eq(['+report'])
    end

    specify 'task with multiple projects' do
      expect(extract_projects('something to do +report +analysis')).to eq(['+report', '+analysis'])
    end
  end

  describe '#extract_priority' do
    specify 'empty task' do
      expect(extract_priority('')).to be nil
    end

    specify 'task without priority' do
      expect(extract_priority('something to do')).to be nil
    end

    specify 'task with priority A' do
      expect(extract_priority('(A) something to do')).to eq('A')
    end

    specify 'task with priority B' do
      expect(extract_priority('(B) something to do')).to eq('B')
    end
  end

  describe '#extract_created_on' do
    specify 'empty task' do
      expect(extract_created_on('')).to be nil
    end

    specify 'task without date' do
      expect(extract_created_on('something to do')).to be nil
    end

    specify 'task with created date' do
      expect(extract_created_on('2016-03-29 something to do')).to eq(Date.new(2016, 03, 29))
    end

    specify 'prioritised task with created date' do
      expect(extract_created_on('(A) 2016-03-29 something to do')).to eq(Date.new(2016, 03, 29))
    end

    specify 'date included in task text' do
      expect(extract_created_on('(A) something to do on 2016-03-29')).to be nil
    end
  end

  describe '#extract_completed_date' do
    specify 'empty task' do
      expect(extract_completed_date('')).to be nil
    end

    specify 'uncompleted task' do
      expect(extract_completed_date('2016-03-29 something to do')).to be nil
    end

    specify 'completed task without date' do
      expect(extract_completed_date('2016-03-29 something to do')).to be nil
    end

    specify 'completed task without date' do
      expect(extract_completed_date('2016-03-29 something to do')).to be nil
    end
  end

  describe '#check_completed_flag' do
    specify 'empty task' do
      expect(check_completed_flag('')).to be false
    end

    specify 'uncompleted task' do
      expect(check_completed_flag('2016-03-29 something to do')).to be false
    end

    specify 'completed task without date' do
      expect(check_completed_flag('x something to do')).to be true
    end

    specify 'completed task with date' do
      expect(check_completed_flag('x 2016-03-29 something to do')).to be true
    end
  end

  describe '#extract_tags' do
    specify 'empty task' do
      expect(extract_tags('')).to eq({})
    end

    specify 'task without tag' do
      expect(extract_tags('something to do')).to be {}
    end

    specify 'task with due date' do
      expect(extract_tags('something to do due:2016-03-30')).to eq(:due => '2016-03-30')
    end

    specify 'task with case-insensitive due date' do
      expect(extract_tags('something to do DUE:2016-03-30')).to eq(:due => '2016-03-30')
    end

    specify 'task with multiple tags' do
      expect(extract_tags('something to do hello:world and foo:bar')).to eq(:hello => 'world', :foo => 'bar')
    end
  end

  describe '#extract_item_text' do
    specify 'empty task' do
      expect(extract_item_text('')).to eq('')
    end

    specify 'task without markup' do
      expect(extract_item_text('something to do')).to eq('something to do')
    end

    specify 'task with date, priority, projects and context' do
      expect(extract_item_text('(A) 2016-03-29 something to do +experiment @work')).to eq('something to do')
    end

    specify 'completed task with projects and context' do
      expect(extract_item_text('x 2016-03-30 2016-03-29 something to do +experiment @work')).to eq('something to do')
    end
  end
end
