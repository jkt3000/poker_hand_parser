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
      end

      def parse_to_json
        parse
        to_json
      end

      # :game_id
      # :game_host
      # :game_name
      # :table_name
      # :table_size
      # :button
      # :currency
      # :played_at
      #
      # PokerStars Zoom Hand #143045674297:  Hold'em No Limit ($0.02/$0.05) - 2015/10/30 13:45:58 ET
      # Table 'ZemUU8uyOTYQAgqnaWQDUA' 6-max Seat #4 is the button
      #
      def parse_game_details
        game_data   = events[:settings].first
        table_data  = events[:settings][1]
        
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

      # Find out everyone in which seats
      def parse_players
        seats = events[:settings].select {|entry| entry.match(/\ASeat \d+/) }
        seats.each do |entry|
          id = entry.match(/\ASeat (\d+):/)[1].to_i
          name_stack = entry.split(":").last
          name = name_stack.match(/([^(]+)/)[1].to_s.strip
          stack = name_stack.match(/\(.(\d+.\d+) in chips\)/)[1].to_f
          player = {name: name, seat: id, stack: stack}
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
          @events[event] ||= results.to_s.gsub(/\n\n/,"\n").gsub(/^A\s*\n\s*^Z/,'').split("\n")
        end
      end

      def to_json
        # noop
      end

      def logger
        LOGGER
      end

    end

  end
end

