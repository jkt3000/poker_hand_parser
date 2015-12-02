module PokerHandParser

  class InvalidCardError < StandardError; end

  module Cards
    SUITS = %w|c s h d|
    CARDS = %w|A K Q J T 9 8 7 6 5 4 3 2|

    extend self

    def from_text(text)
      cards = text.gsub(/\[|\]/,'').split(/\s+/)
      return [] unless cards.length > 0
      cards.map do |card|
        raise InvalidCardError, "Card error: bad value #{card}" unless CARDS.include?(card[0])
        raise InvalidCardError, "Card error: bad suit #{card}" unless SUITS.include?(card[1])
        card
      end
    end
  end
end