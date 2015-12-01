module PokerHandParser
  module Pokerstars

    class HandParser

      PARSER_TYPE = "Pokerstars"
      LOGGER      = Logger.new(STDOUT)
      MARKERS     = {
        settings: nil,
        preflop:  "*** HOLE CARDS ***",
        flop:     "*** FLOP ***",
        turn:     "*** TURN ***",
        river:    "*** RIVER ***",
        showdown: "*** SHOW DOWN ***",
        summary:  "*** SUMMARY ***"
      }

      EVENT_ORDER = [:settings, :preflop, :flop, :turn, :river, :showdown, :summary]

      VALID_PLAYER_ACTIONS = %w|calls folds bets raises checks|

      attr_accessor :game_details, 
                    :parsed_at, 
                    :players, 
                    :actions, 
                    :results,
                    :raw_events, :events

      def initialize(events)
        @raw_events   = events
        @events       = {}
        @type         = PARSER_TYPE.dup
        @game_details = {}
        @players      = []
        @actions      = {}
        @results      = {}

        process_events        
      end

      def parse
        parse_game_details
        parse_players
        parse_preflop
        parse_flop
        parse_turn
        parse_river
        summarize_results
        @parsed_at = Time.now.utc
        to_hash
      rescue ParseError => e
        logger.debug("Error parsing hand history: #{e}")
        nil
      end

      def parse_game_details
        raise ParseError, "Settings data is blank" unless events[:settings] 
        # should fail earlier, on init?
        game_data  = events[:settings].first
        table_data = events[:settings][1]
        
        raise ParseError, "Game data is blank" if game_data.blank? 
        raise ParseError, "Table data is blank" if table_data.blank?

        game_id, remainder = game_data.split(": ", 2)
        game_name, date = remainder.split(" - ", 2)

        if m = game_id.match(/\#(\d{5,14})/)
          @game_details[:game_id] = m[1].strip
        end
        @game_details[:played_at]  = Time.parse(date)
        @game_details[:game_name]  = game_name.strip
        @game_details[:game_host]  = PARSER_TYPE
        @game_details[:table_name] = table_data.match(/Table \'(.+)\'/)[1]
        @game_details[:table_size] = table_data.match(/(\d)\-max/)[1].to_i
        @game_details[:button]     = table_data.match(/Seat \#(\d)/)[1].to_i
      end

      def parse_players
        seats = events[:settings].select {|entry| entry.match(/\ASeat \d+/) }
        seats.each do |entry|
          id         = entry.match(/\ASeat (\d+):/)[1].to_i
          name_stack = entry.split(":").last
          name       = name_stack.match(/([^(]+)/)[1].to_s.strip
          stack      = name_stack.match(/\(.(\d+.\d+) in chips\)/)[1].to_f
          player     = {name: name, seat: id, stack: stack}
          @players << player
        end
      end

      def parse_pregame
        # parse the antes and sb/bb
        entries = events[:settings]

      end

      def parse_preflop
        parse_actions(events[:preflop])
      end

      def parse_flop
        parse_actions(events[:flop])
      end

      def parse_turn
        parse_actions(events[:turn])
      end

      def parse_river
        parse_actions(events[:river])
      end

      def summarize_results
        # noop
      end


#       sp4le87: posts small blind 10
# Kolyan0023: posts big blind 20
# *** HOLE CARDS ***
# Dealt to toppair [4d Qh]
# sp4le87: folds 
# Kolyan0023: folds 
# *** FLOP *** [8c Jh 7s]
# *** TURN *** [8c Jh 7s] [Ac]
# *** RIVER *** [8c Jh 7s Ac] [3s]
# *** SHOW DOWN ***



      # {
      #   seat: x,
      #   action: 'bets | raises | calls | checks | folds | disconnected ',
      #   amount: 10,
      #   cards: [As, Kd]
      # }
      # break action entry into hash of possible actions


      def parse_actions(entries)
        entries.each do |entry|
          if entry.include?(": ")
            parse_player_action(entry)
          else
            parse_system_action(entry)
          end
        end
      end

      def parse_player_action(entry)
        name, actions = entry.split(": ", 2)
        tokens = actions.split(" ")
        action = tokens.first
        
        raise ParseError, "Invalid player action: #{action}" unless VALID_PLAYER_ACTIONS.include?(action)

        if tokens.count > 1
          amt_token = action == "raises" ? tokens[3] : tokens[1]
          amount = if m = amt_token.match(/(\d+\.\d+|\d+)/)
            m[1]
          end
        end
        
        {
          seat: lookup_seat_by_name(name),
          action: action,
          amount: amount ? amount.to_f : nil,
          all_in: tokens.include?("all-in")
        }
      end

      # just handle disconnection, ignore chats and everything else
      # Paul HSV is disconnected 
      def parse_system_action(entry)
        return nil unless entry.include?(" is disconnected")
        name, _ = entry.split(" is disconnected")

        {
          seat: lookup_seat_by_name(name),
          action: "disconnects"
        }
      end

      def small_blind_action(entry)

      end


      private

      def lookup_player_by_name(name)
        players.detect {|p| p[:name] == name }
      end

      def lookup_seat_by_name(name)
        if player = lookup_player_by_name(name)
          player.fetch(:seat)
        end
      end

      # break events into different categories (settings, preflop, flop, turn, river, summary)
      def process_events
        remaining = raw_events
        EVENT_ORDER.reverse.each do |event|
          marker = MARKERS[event]
          if marker.present?
            remaining, results = remaining.split(MARKERS[event],2)
          else
            results = remaining
          end
          #logger.debug("Found for event '#{event}':\n#{results}")
          @events[event] ||= results.to_s.gsub(/\n\n/,"\n").gsub(/^$\n/,'').split("\n")
          # remove any leading and ending blank lines
        end
      end

      def to_hash
        {
          game_id:    game_details[:game_id],
          game_host:  game_details[:game_host],
          game_name:  game_details[:game_name],
          table_name: game_details[:table_name],
          table_size: game_details[:table_size],
          button:     game_details[:button],
          played_at:  game_details[:played_at],
          players:    players,
          actions:    actions,
          results:    results,
          parsed_at:  parsed_at,
        }
      end

      def logger
        LOGGER
      end

    end

  end
end

