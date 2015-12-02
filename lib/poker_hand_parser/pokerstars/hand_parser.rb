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
        @actions[:deal]     = parse_pregame
        @actions[:preflop]  = parse_actions(events[:preflop])
        @actions[:flop]     = parse_actions(events[:flop])
        @actions[:turn]     = parse_actions(events[:turn])
        @actions[:river]    = parse_actions(events[:river])
        @actions[:showdown] = parse_actions(events[:showdown])
        @results = summarize_results
        @parsed_at = Time.now.utc
        to_hash
      rescue ParseError => e
        logger.info("Error parsing hand history: #{e}")
        p e
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

      # parse antes and sb/bb
      def parse_pregame
        index = 0
        events[:settings].each_with_index do |entry, i|
          index = i if entry.match(/^Seat /)
        end
        
        actions = events[:settings][index+1..-1]
        parse_actions(actions)
      end

      def summarize_results
        pot, rake = events[:summary].first.split(" | ")
        {
          total_pot: amount_from_token(pot.gsub("Total pot ", '')),
          rake: amount_from_token(rake.gsub("Rake ", ''))
        }
      end

      def parse_actions(entries)
        # first entry is cards dealt?
        entries.map do |entry|
          entry.include?(": ") ? parse_player_action(entry) : parse_system_action(entry)
        end.compact
      end

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
            cards = parse_cards_list(tokens[1..2].join(" "))
            description = tokens[4..-1].join(" ").gsub(/\(|\)/,'')
            # parse end hand in description
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

      # just handle disconnection, ignore chats and everything else
      # Paul HSV is disconnected 
      def parse_system_action(entry)
        return parse_disconnect_action(entry) if entry.match(/ is disconnected$/)
        return parse_deal(entry) if entry.match(/^\[\w{2}/)
        
        if entry.match(/^Dealt to/)
          entry.gsub!(/Dealt to /,'')
          name, cards_entry = entry.split(" [")
          return parse_deal(cards_entry, name)
        end

        if entry.match(/ collected /)
          return parse_collected(entry)
        end
      end

      def parse_disconnect_action(entry)
        name, _ = entry.split(" is disconnected")
        {
          seat: lookup_seat_by_name(name),
          action: "disconnects"
        }
      end

      # Dealt to toppair [Qd Tc]
      def parse_deal(card_list, name = nil)
        cards = parse_cards_list(card_list)
        {
          seat: lookup_seat_by_name(name),
          action: 'deal',
          cards: cards
        }
      end

      #Edwin collected $151.50 from pot
      #Amy Adams collected $151.50 from pot
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

      # converts [xx xx] into array of card strings
      def parse_cards_list(entry)
        cards = entry.gsub(/\[|\]/,'').split(/\s+/)
        PokerHandParser::Cards.validate!(cards)
        cards
      end

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

