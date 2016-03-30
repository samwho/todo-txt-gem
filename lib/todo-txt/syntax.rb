module Todo
  module Syntax
    # The regular expression used to match contexts.
    CONTEXTS_PATTERN = /(?:\s+|^)@[^\s]+/.freeze

    # The regex used to match projects.
    PROJECTS_PATTERN = /(?:\s+|^)\+[^\s]+/.freeze

    # The regex used to match priorities.
    PRIORITY_PATTERN = /(?:^|\s+)\(([A-Za-z])\)\s+/

    # The regex used to match creation date.
    CREATED_ON_PATTERN = /(?:^|-\d{2}\s|\)\s)(\d{4}-\d{2}-\d{2})\s/.freeze

    # The regex used to match completion.
    COMPLETED_ON_PATTERN = /^x\s+(\d{4}-\d{2}-\d{2})\s+/.freeze

    # The regex used to match due date.
    DUE_ON_PATTERN = /(?:due:)(\d{4}-\d{2}-\d{2})(?:\s+|$)/i.freeze

    def get_item_text(line)
      line.
        gsub(COMPLETED_ON_PATTERN, '').
        gsub(PRIORITY_PATTERN, '').
        gsub(CREATED_ON_PATTERN, '').
        gsub(CONTEXTS_PATTERN, '').
        gsub(PROJECTS_PATTERN, '').
        gsub(DUE_ON_PATTERN, '').
        strip
    end

    def orig_priority(line)
      line.match(PRIORITY_PATTERN)[1] if line =~ PRIORITY_PATTERN
    end

    def orig_created_on(line)
      begin
        if line =~ CREATED_ON_PATTERN
          date = line.match CREATED_ON_PATTERN
          return Date.parse(date[1]) unless date.nil?
        end
      rescue; end
      nil
    end

    def get_completed_date(line)
      begin
        return Date.parse(COMPLETED_ON_PATTERN.match(line)[1])
      rescue; end
      nil
    end

    def get_due_on_date(line)
      begin
        return Date.parse(DUE_ON_PATTERN.match(line)[1])
      rescue; end
      nil
    end

    # Extract the list of `@context` tags out of the task line.
    #
    # @param [String] line Line of text encoding a single task
    # @return [Array<String>] List of context tags
    def extract_context_tags(line)
      line.scan(CONTEXTS_PATTERN).map { |tag| tag.strip }
    end

    # Extract the list of `+project` tags out of the task line.
    #
    # @param [String] line Line of text encoding a single task
    # @return [Array<String>] List of project tags
    def extract_project_tags(line)
      line.scan(PROJECTS_PATTERN).map { |tag| tag.strip }
    end
  end
end
