module Todo
  module Syntax
    # The regular expression used to match contexts.
    def contexts_regex
       /(?:\s+|^)@[^\s]+/
    end

    # The regex used to match projects.
    def projects_regex
       /(?:\s+|^)\+[^\s]+/
    end

    # The regex used to match priorities.
    def priority_regex
      /(?:^|\s+)\(([A-Za-z])\)\s+/
    end

    # The regex used to match creation date.
    def created_on_regex
      /(?:^|-\d{2}\s|\)\s)(\d{4}-\d{2}-\d{2})\s/
    end

    # The regex used to match completion.
    def done_regex
      /^x\s+(\d{4}-\d{2}-\d{2})\s+/
    end

    # The regex used to match due date.
    def due_on_regex
      /(?:due:)(\d{4}-\d{2}-\d{2})(?:\s+|$)/i
    end

    def orig_priority(line)
      line.match(priority_regex)[1] if line =~ priority_regex
    end

    def orig_created_on(line)
      begin
        if line =~ created_on_regex
          date = line.match created_on_regex
          return Date.parse(date[1]) unless date.nil?
        end
      rescue; end
      nil
    end

    def get_completed_date(line)
      begin
        return Date.parse(done_regex.match(line)[1])
      rescue; end
      nil
    end

    def get_due_on_date(line)
      begin
        return Date.parse(due_on_regex.match(line)[1])
      rescue; end
      nil
    end

    def get_context_tags(line)
      line.scan(contexts_regex).map { |tag| tag.strip }
    end

    def get_project_tags(line)
      line.scan(projects_regex).map { |tag| tag.strip }
    end
  end
end
