module Todo
  class << self
    attr_accessor :options_instance
  end

  def self.options
    self.options_instance ||= Options.new
  end

  def self.customize
    self.options_instance ||= Options.new
    yield(options_instance)
  end

  class Options
    # Require all done tasks to have a `completed_on` date. True by default.
    #
    # - When `true`, tasks with invalid dates are considered not done.
    # - When `false`, tasks starting with `x ` are considered done.
    #
    # @return [Boolean]
    attr_accessor :require_completed_on

    # PENDING
    #
    # Whether or not to preserve original field order for roundtripping.
    #
    # @return [Boolean]
    attr_accessor :maintain_field_order

    def initialize
      reset
    end

    # Reset to defaults.
    def reset
      @require_completed_on = true
      @maintain_field_order = false
    end
  end
end
