module PokerHandParser
  module Pokerstars

    class HandParser

      PARSER_TYPE = "Pokerstars"
      MARKERS     = {
        settings: nil,
        preflop:  "*** HOLE CARDS ***",
        flop:     "*** FLOP ***",
        turn:     "*** TURN ***",
        river:    "*** RIVER ***",
        showdown: "*** SHOW DOWN ***",
        summary:  "*** SUMMARY ***"
      }
      EVENT_ORDER          = [:settings, :preflop, :flop, :turn, :river, :showdown, :summary]
      VALID_PLAYER_ACTIONS = %w|calls folds bets raises checks posts shows|

      attr_accessor :game_details, 
                    :parsed_at, 
                    :players, 
                    :actions, 
                    :results,
                    :raw_events, :events

      def initialize(events)
        @raw_events   = events
        @events       = {}
        @game_details = {}
        @actions      = {}
        @results      = {}
        process_events        
        parse_game_details
        parse_players
      end

      def parse
        parse_pregame
        @actions[:preflop]  = parse_actions(events[:preflop])
        @actions[:flop]     = parse_actions(events[:flop])
        @actions[:turn]     = parse_actions(events[:turn])
        @actions[:river]    = parse_actions(events[:river])
        @actions[:showdown] = parse_actions(events[:showdown])
        @results            = summarize_results
        @parsed_at          = Time.now.utc
        to_hash
      rescue ParseError => e
        logger.info("Error parsing hand history: #{e}")
        nil
      end

      def parse_game_details
        raise InvalidHandHistoryError, "Settings data is blank" unless events[:settings] 
        # should fail earlier, on init?
        game_data  = events[:settings].first
        table_data = events[:settings][1]
        
        raise InvalidHandHistoryError, "Game data is blank" if game_data.blank? 
        raise InvalidHandHistoryError, "Table data is blank" if table_data.blank?

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
        seats = events[:settings].select {|entry| entry.match(/^Seat \d+/) }
        @players = seats.map {|entry| extract_player_info(entry) }.compact
      end

      # Seat 4: tigriskem ($14.69 in chips)
      def extract_player_info(entry)
        if m = entry.match(/\ASeat (\d+):/)
          id = m[1].to_i
        end

        text = entry.gsub(/Seat \d+\: /, "")
        if m = text.match(/(.+) \(.?(\d+\.?\d*) in chips\)/)
          name  = m[1].to_s.strip
          stack = m[2].to_f
        end
        {name: name, seat: id, stack: stack} if name && id && stack
      end

      # parse antes and sb/bb
      # Dave: posts small blind $5
      # Edwin: posts big blind $10
      def parse_pregame
        index = 0
        events[:settings].each_with_index do |entry, i|
          index = i if entry.match(/^Seat /)
        end
        
        actions = events[:settings][index+1..-1]
        @actions[:deal] = parse_actions(actions)
      end

      # parse pot and rake size, ignore remaining entries
      # Total pot $305 | Rake $2
      def summarize_results
        raise ParseError, "missing summary entries" if events.fetch(:summary, []).empty?
        pot, rake = events[:summary].first.split(" | ")
        {
          total_pot: amount_from_token(pot.gsub("Total pot ", '')),
          rake: amount_from_token(rake.gsub("Rake ", ''))
        }
      end

      def parse_actions(entries)
        entries.map do |entry|
          entry.include?(": ") ? parse_player_action(entry) : parse_system_action(entry)
        end.compact
      end

      # eg: Edwin: bets $20
      def parse_player_action(entry)
        name, actions = entry.split(": ", 2)
        tokens        = actions.split(" ")
        action        = tokens.first
        amount        = nil
        description   = nil        
        raise ParseError, "Invalid player action: #{action}" unless VALID_PLAYER_ACTIONS.include?(action)

        case action
          when 'posts'
            amount      = amount_from_token(tokens[3])
            description = tokens[1..2].join(' ')
          when 'raises'
            amount = amount_from_token(tokens[3])
          when 'shows'
            cards       = PokerHandParser::Cards.from_text(tokens[1..2].join(" "))
            description = tokens[4..-1].join(" ").gsub(/\(|\)/,'')
          else
            amount = amount_from_token(tokens[1])
        end
        
        result = {
          seat: lookup_seat_by_name(name),
          action: action,
          amount: amount,
        }
        result.merge!(all_in: true) if tokens.include?("all-in")
        result.merge!(description: description) if description
        result.merge!(cards: cards) if cards
        result
      end

      def parse_system_action(entry)
        # disconnection
        return parse_disconnect_action(entry) if entry.match(/ is disconnected$/)

        # flop,turn.river cards
        return parse_deal(entry) if entry.match(/^\[\w{2}/)
        
        # collecting pot
        return parse_collected(entry) if entry.match(/ collected /)
          
        # dealt hole cards
        if entry.match(/^Dealt to/)
          entry.gsub!(/Dealt to /,'')
          name, cards_entry = entry.split(" [")
          return parse_deal(cards_entry, name)
        end
      end

      # eg: Paul HSV is disconnected 
      def parse_disconnect_action(entry)
        name, _ = entry.split(" is disconnected")
        {
          seat: lookup_seat_by_name(name),
          action: "disconnects"
        }
      end

      # Dealt to toppair [Qd Tc]
      def parse_deal(card_list, name = nil)
        cards = PokerHandParser::Cards.from_text(card_list)
        {
          seat: lookup_seat_by_name(name),
          action: 'deal',
          cards: cards
        }
      end

      # Edwin collected $151.50 from pot
      def parse_collected(entry)
        name, list = entry.split(" collected ")
        amount = amount_from_token(list)
        {
          seat: lookup_seat_by_name(name),
          action: 'collected',
          amount: amount_from_token(list)
        }
      end

      private

      def amount_from_token(token)
        return unless token
        return unless matches = token.match(/(\d+\.\d+|\d+)/)
        matches[1].to_f
      end

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
          logger.debug("Found for event '#{event}':\n#{results}")
          @events[event] ||= begin
            # remove blank lines and split by new lines
            events = results.to_s.gsub(/\n\n/,"\n").gsub(/^$\n/,'').split("\n") 
            events.map {|e| e.strip! }  # strip leading and ending whitespaces
            events
          end
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
        PokerHandParser.logger
      end

    end

  end
end

