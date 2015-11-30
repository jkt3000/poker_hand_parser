require 'rubygems'
require 'active_support'
require 'active_support/test_case'
require "minitest/autorun"

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'poker_hand_parser'


ActiveSupport.test_order = :random

class ActiveSupport::TestCase

  def input_file(filename)
    File.join(fixture_path, filename)
  end


  def fixture_path
    File.expand_path(File.dirname(__FILE__) + "/fixtures")
  end
  def read_file(filename)
    File.read(input_file(filename))
  end

end