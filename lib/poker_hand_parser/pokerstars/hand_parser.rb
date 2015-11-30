module PokerHandParser
  module Pokerstars

    class ParseError < StandardError; end

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


      def parse_preflop
        # noop
      end

      def parse_flop
        # noop
      end

      def parse_turn
        # noop
      end

      def parse_river
        # noop
      end

      def summarize_results
        # noop
      end

      private

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
          game_id: game_details[:game_id],
          game_host: game_details[:game_host],
          game_name: game_details[:game_name],
          table_name: game_details[:table_name],
          table_size: game_details[:table_size],
          button: game_details[:button],
          played_at: game_details[:played_at],
          players: players,
          actions: actions,
          results: results,
          parsed_at: parsed_at,
        }
      end

      def logger
        LOGGER
      end

    end

  end
end

