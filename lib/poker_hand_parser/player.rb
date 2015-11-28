require 'json'

module PokerHandParser
  
  class Player

    attr_accessor :name, :seat, :stack

    def initialize(name: name, seat: seat, stack: 0)
      @name = name
      @seat = seat
      @stack = stack
    end

    def to_hash
      {
        name: @name,
        seat: @seat,
        stack: @stack
      }
    end

    def to_json
      to_hash.to_json
    end
  end

end
