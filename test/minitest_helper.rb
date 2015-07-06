$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'banditmask'

require 'minitest/autorun'

begin
  require 'pry'
  require 'minitest/focus'
  require 'minitest/reporters'
  Minitest::Reporters.use! Minitest::Reporters::DefaultReporter.new
rescue LoadError
end
