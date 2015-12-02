require 'test_helper'

class CardsTest < ActiveSupport::TestCase
    
  test "#validate! can validate array of 1 card" do
    cards = ['As']
    assert PokerHandParser::Cards.validate!(cards)
  end

  test "#validate! can validate array of many cards" do
    cards = ['As', 'Kh', '3c']
    assert PokerHandParser::Cards.validate!(cards)
  end

  test "#validate! raises exception if suit of a card is invalid" do
    cards = ['Ar']
    assert_raises PokerHandParser::InvalidCardError do
      assert PokerHandParser::Cards.validate!(cards)
    end
  end

  test "#validate! raises exception if value of a card is invalid" do
    cards = ['1c']
    assert_raises PokerHandParser::InvalidCardError do
      assert PokerHandParser::Cards.validate!(cards)
    end
  end

end
