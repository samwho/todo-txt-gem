module Todo
  module Syntax
    # The regex used to match contexts.
    CONTEXTS_PATTERN = /(?:\s+|^)@[^\s]+/

    # The regex used to match projects.
    PROJECTS_PATTERN = /(?:\s+|^)\+[^\s]+/

    # The regex used to match priorities.
    PRIORITY_PATTERN = /(?:^|\s+)\(([A-Za-z])\)\s+/

    # The regex used to match creation date.
    CREATED_ON_PATTERN = /(?:^|-\d{2}\s|\)\s)(\d{4}-\d{2}-\d{2})\s/

    # The regex used to match completion.
    COMPLETED_ON_PATTERN = /^x\s+(\d{4}-\d{2}-\d{2})\s+/

    # The regex used to match due date.
    DUE_ON_PATTERN = /(?:due:)(\d{4}-\d{2}-\d{2})(?:\s+|$)/i

    # Extracts the readable text content of a task line, stripping out all the
    # discrete pieces of metadata (priority, dates, completion flag, projects,
    # contexts, etc).
    #
    # @param line [String] the todo item to be processed
    # @return [String] the text content of the item
    def extract_item_text(line)
      line.
        gsub(COMPLETED_ON_PATTERN, '').
        gsub(PRIORITY_PATTERN, '').
        gsub(CREATED_ON_PATTERN, '').
        gsub(CONTEXTS_PATTERN, '').
        gsub(PROJECTS_PATTERN, '').
        gsub(DUE_ON_PATTERN, '').
        strip
    end

    # Extracts the priority indicator from the task line.
    #
    # @param line [String] the todo item to be processed
    # @return [String] the character (from A-Z) representing the priority
    def extract_priority(line)
      line.match(PRIORITY_PATTERN)[1] if line =~ PRIORITY_PATTERN
    end

    # Extracts the creation date for the given todo item.
    # Returns nil if a valid date is not found.
    #
    # @param line [String] the todo item to be processed
    # @return [Date] the created date of the line
    def extract_created_on(line)
      date = line.match CREATED_ON_PATTERN
      begin
        Date.parse(date[1]) if date
      rescue ArgumentError
        return nil # The given date is not valid
      end
    end

    # Extracts the completion date for the given todo item.
    # Returns nil if a valid date is not found.
    #
    # @param line [String] the todo item to be processed
    # @return [Date] the completed date of the line
    def extract_completed_date(line)
      date = COMPLETED_ON_PATTERN.match(line)
      begin
        Date.parse(date[1]) if date
      rescue ArgumentError
        return nil # The given date is not valid
      end
    end

    COMPLETED_FLAG = 'x'.freeze
    SINGLE_SPACE = ' '.freeze

    # Checks whether the given todo item has a completion flag set.
    #
    # This provides support for ad-hoc handwritten lists where the completed flag
    # is set but there is no completed date.
    #
    # @param line [String] the todo item to be processed
    # @return [Boolean]
    def check_completed_flag(line)
      line[0] == COMPLETED_FLAG && line[1] == SINGLE_SPACE
    end

    # Extracts the completion date for the given todo item.
    # Returns nil if a valid date is not found.
    #
    # @param line [String] the todo item to be processed
    # @return [Date] the due date of the line
    def extract_due_on_date(line)
      date = DUE_ON_PATTERN.match(line)
      begin
        Date.parse(date[1]) if date
      rescue ArgumentError
        return nil # The given date is not valid
      end
    end

    # Extract the list of `@context` tags out of the task line.
    #
    # @param [String] line Line of text encoding a single task
    # @return [Array<String>] List of context tags
    def extract_contexts(line)
      line.scan(CONTEXTS_PATTERN).map { |tag| tag.strip }
    end

    # Extract the list of `+project` tags out of the task line.
    #
    # @param [String] line Line of text encoding a single task
    # @return [Array<String>] List of project tags
    def extract_projects(line)
      line.scan(PROJECTS_PATTERN).map { |tag| tag.strip }
    end
  end
end
