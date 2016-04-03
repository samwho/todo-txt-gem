require 'logger'

module Todo
  # Handles depreciation warnings and other issues related to API usage
  module Logger
    def self.included(base)
      base.extend(self)
    end

    def logger
      Todo::Logger.logger
    end

    class << self
      # Sets a new logger object
      attr_writer :logger

      # Creates a new logger object
      def logger
        @logger ||= ::Logger.new(STDOUT)
      end
    end
  end
end
