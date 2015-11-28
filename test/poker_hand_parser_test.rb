require 'test_helper'



class PokerHandParserTest < ActiveSupport::TestCase
    
  setup do

  end

  test "true" do
    assert true
  end

  test "import file" do
    @input_file = input_file('ps_hands.txt')
    PokerHandParser.import(@input_file)
  end
end