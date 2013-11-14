require 'logger'

module Todo
  module Logger
    def self.included base
      base.extend(self)
    end

    def self.logger= new_logger
      @@logger = new_logger
    end

    def self.logger
      @@logger ||= ::Logger.new(STDOUT)
    end

    def logger
      Todo::Logger.logger
    end
  end
end
