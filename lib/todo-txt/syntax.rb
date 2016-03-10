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
  end
end
