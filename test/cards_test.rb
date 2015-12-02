require 'test_helper'

class CardsTest < ActiveSupport::TestCase

  test "#from_text returns array of validated cards" do
    text = "[As Kd Qh Jc Th 9s 8d 7h 6c 5s 4c 3h 2c]"
    assert_equal 13, PokerHandParser::Cards.from_text(text).count

    text = "As Kd Qh Jc Th 9s 8d 7h 6c 5s 4c 3h 2c"
    assert_equal 13, PokerHandParser::Cards.from_text(text).count

    text = "[As"
    assert_equal 1, PokerHandParser::Cards.from_text(text).count

    text = "As]"
    assert_equal 1, PokerHandParser::Cards.from_text(text).count     
  end

  test "#from_text returns empty array if no valid cards were found" do
    text = "[]"
    assert_equal 0, PokerHandParser::Cards.from_text(text).count
  end

  test "#from_text raises exception if value is invalid" do
    assert_raises PokerHandParser::InvalidCardError do
      PokerHandParser::Cards.from_text("1h")
    end
  end 
    
  test "#from_text raises exception if suit is invalid" do
    assert_raises PokerHandParser::InvalidCardError do
      PokerHandParser::Cards.from_text("Ar")
    end
  end 
end
