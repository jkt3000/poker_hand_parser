module PokerHandParser
  class HandParser

    HOST = "Default"

    attr_accessor :hand_id, :played_at, :parsed_at, :parser, 
                  :table, :actions, :results

    def initialize(history)
      @hand_history = history
      @type         = HOST.dup
      @parsed_at    = Time.now.utc

      # break up hands into sections 
        # - details
        # - hole cards
        # - flop
        # - turn
        # - river
        # - show down
        # - summary
    end

    def parse
      parse_table_details
      parse_players
      parse_button
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


    def parse_table_details
      # noop
    end

    def parse_players
      # noop
    end

    def parse_button
      # noop
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

    def to_json
      # noop
    end

  end
end


# PokerStars Game #59950643732:  Hold'em No Limit ($5/$10) - 2009/07/01 6:57:14 ET
# Table 'ZemUU8uyOTYQAgqnaWQDUA' 6-max Seat #4 is the button
# Seat 2: NczJqEIUdrpEc5Nbd7h1Ig ($591 in chips)
# Seat 3: M6ck0CntRJiM0JZjUketMw ($439 in chips)
# Seat 4: M5+Fo1NDPI9ulpVSsqNsNw ($354.10 in chips)
# Seat 5: 33XJu1CVnl9YOngoPIhi0A ($834.45 in chips)
# Seat 6: 3mTlg4g0FJN2bo939h/0Wg ($275 in chips)
# 33XJu1CVnl9YOngoPIhi0A: posts small blind $5
# 3mTlg4g0FJN2bo939h/0Wg: posts big blind $10
# *** HOLE CARDS ***
# NczJqEIUdrpEc5Nbd7h1Ig: calls $10
# M6ck0CntRJiM0JZjUketMw: folds
# M5+Fo1NDPI9ulpVSsqNsNw: folds
# 33XJu1CVnl9YOngoPIhi0A: folds
# 3mTlg4g0FJN2bo939h/0Wg: checks
# *** FLOP *** [6h 7s 5h]
# 3mTlg4g0FJN2bo939h/0Wg: bets $20
# NczJqEIUdrpEc5Nbd7h1Ig: calls $20
# *** TURN *** [6h 7s 5h] [3s]
# 3mTlg4g0FJN2bo939h/0Wg: checks
# NczJqEIUdrpEc5Nbd7h1Ig: checks
# *** RIVER *** [6h 7s 5h 3s] [Td]
# 3mTlg4g0FJN2bo939h/0Wg: bets $40
# NczJqEIUdrpEc5Nbd7h1Ig: raises $80 to $120
# 3mTlg4g0FJN2bo939h/0Wg: calls $80
# *** SHOW DOWN ***
# NczJqEIUdrpEc5Nbd7h1Ig: shows [Qh 4c] (a straight, Three to Seven)
# 3mTlg4g0FJN2bo939h/0Wg: shows [7d 4s] (a straight, Three to Seven)
# 3mTlg4g0FJN2bo939h/0Wg collected $151.50 from pot
# NczJqEIUdrpEc5Nbd7h1Ig collected $151.50 from pot
# *** SUMMARY ***
# Total pot $305 | Rake $2
# Board [6h 7s 5h 3s Td]
# Seat 2: NczJqEIUdrpEc5Nbd7h1Ig showed [Qh 4c] and won ($151.50) with a straight, Three to Seven
# Seat 3: M6ck0CntRJiM0JZjUketMw folded before Flop (didn't bet)
# Seat 4: M5+Fo1NDPI9ulpVSsqNsNw (button) folded before Flop (didn't bet)
# Seat 5: 33XJu1CVnl9YOngoPIhi0A (small blind) folded before Flop
# Seat 6: 3mTlg4g0FJN2bo939h/0Wg (big blind) showed [7d 4s] and won ($151.50) with a straight, Three to Seven

