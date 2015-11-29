module PokerHandParser

  # table model
  # - name (some sites have names for a table)
  # - host (PokerStars, Bovada, Partypoker, 888, ...)
  # - type (Zoom NL Holdem, NL Holdem, ...)
  # - currency ($, chips, ...)
  # - max_size (max size table will hold, ie: 9)
  # - players (array [0..max_size-1] of Player, 0 => seat1)
  class Table

    attr_accessor :name, :host, :type, :currency, :max_size, :players

    def initialize(name: name, host: host, type: type, currency: currency, max_size: max_size, players: [])
        @name     = name
        @host     = host
        @type     = type
        @currency = currency
        @max_size = max_size
        @players  = players
    end

    def seat(index)
      index = index.to_i
      return if index > players.count + 1 || index < 1
      players[index - 1]
    end

    def seating_map
      @max_size.times.inject({}) do |seating, i|
        seating["seat#{i + 1}".to_sym] = players[i] ? players[i].to_hash : nil
        seating
      end
    end

    def players_count
      players.count
    end

    def add_player(params)
      player = params.is_a?(PokerHandParser::Player) ? params : PokerHandParser::Player.new(params)
      @players[player.seat - 1] = player
    end

    def to_json
      {
        name: name,
        host: host,
        type: type,
        currency: currency,
        max_size: max_size,
        players: players.compact.map(&:to_hash)
      }.to_json
    end
  end

end