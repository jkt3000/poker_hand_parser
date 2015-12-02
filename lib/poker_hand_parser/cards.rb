module PokerHandParser

  class InvalidCardError < StandardError; end

  module Cards
    SUITS = %w|c s h d|
    CARDS = %w|A K Q J T 9 8 7 6 5 4 3 2|

    extend self

    # validates that cards passed in are valid
    def validate!(cards = [])
      cards.each do |card|
        raise InvalidCardError, "invalid Suit" unless SUITS.include?(card[1])
        raise InvalidCardError, "invalid Value" unless CARDS.include?(card[0])        
      end
    end
  end
end