require 'date'
require 'timecop'
require 'simplecov'

SimpleCov.start

require File.join(File.dirname(__FILE__), "../lib/todo-txt.rb")

RSpec.configure do |config|
  config.expect_with(:rspec) do |c|
    c.syntax = :expect
  end
end
