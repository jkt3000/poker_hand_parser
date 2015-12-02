require 'test_helper'
require 'pp'

class PokerHandParser::Pokerstars::HandParserTest < ActiveSupport::TestCase

  setup do
    @parser = PokerHandParser::Pokerstars::HandParser.new(read_file("pokerstars/hand1.txt"))
  end

  # create

  test "#create instance of Pokerstars::HandParser breaks raw events into categories" do
    assert @parser.events[:settings].present?
    assert @parser.events[:preflop].present?
    assert @parser.events[:flop].present?
    assert @parser.events[:turn].present?
    assert @parser.events[:river].present?
    assert @parser.events[:summary].present?
  end

  test "#create breaks events into categories when missing some events" do
    @parser = PokerHandParser::Pokerstars::HandParser.new(read_file("pokerstars/hand2.txt"))
    assert @parser.events[:settings].present?
    assert @parser.events[:preflop].present?
    assert @parser.events[:flop].blank?
    assert @parser.events[:turn].blank?
    assert @parser.events[:river].blank?
    assert @parser.events[:summary].present?
  end

  test "#create should raise error if input is not a valid pokerstars hand history file" do
    assert_raises PokerHandParser::InvalidHandHistoryError do 
      @parser = PokerHandParser::Pokerstars::HandParser.new("some invalid file")
    end
  end

  # parse

  test "#parse returns hash of processed hand history" do
    response = @parser.parse

    #pp response

    assert_equal game_keys.sort, response.keys.sort
    assert_equal action_keys.sort, response[:actions].keys.sort
    assert_equal "59950643732", response[:game_id]
    assert_equal 6, response[:table_size]
    assert_equal 5, response[:players].count
    assert_equal 4, response[:button]
    assert_equal "Pokerstars", response[:game_host]
    assert_equal "Hold'em No Limit ($5/$10)", response[:game_name]
    assert_equal "AlphaTable", response[:table_name]
  end

  test "#parse returns hash of processed tournament hand history" do
    @parser = PokerHandParser::Pokerstars::HandParser.new(read_file("pokerstars/tourney_hand.txt"))
    response = @parser.parse

    assert_equal game_keys.sort, response.keys.sort
    assert_equal action_keys.sort, response[:actions].keys.sort
  end

  # parse_game_details

  test "#parse_game_details extracts parameters for cash game" do
    @parser.parse_game_details
    @game = @parser.game_details
    assert_equal "59950643732", @game[:game_id]
    assert_equal "Hold'em No Limit ($5/$10)", @game[:game_name]
    assert_equal "Pokerstars", @game[:game_host]
    assert_equal Time.parse("2009/07/01 6:57:14 ET"), @game[:played_at]
    assert_equal 6, @game[:table_size]
    assert_equal "AlphaTable", @game[:table_name]
    assert_equal 4, @game[:button]
  end

  test "#parse_game_details extracts parameters for tournament game" do
    @parser = PokerHandParser::Pokerstars::HandParser.new(read_file("pokerstars/tourney_hand.txt"))
    @parser.parse_game_details
    @game = @parser.game_details

    assert_equal "143332391801", @game[:game_id]
    assert_equal "Tournament #1370571394, $0.45+$0.05 USD Hold'em No Limit",  @game[:game_name]
    assert_equal 9, @game[:table_size]
    assert_equal "1370571394 3", @game[:table_name]
    assert_equal 2, @game[:button]
  end

  # parse_players

  test "#parse_players builds players from game data" do
    @parser.parse_players
    assert_equal 5, @parser.players.count
    @parser.players.all? {|player| assert player[:stack] > 0 }
    
    player = @parser.players.first
    assert_equal "Amy Adams", player[:name]
    assert_equal 2, player[:seat]
    assert_equal 591, player[:stack].to_i

    player = @parser.players[1]
    assert_equal "Billy", player[:name]
    assert_equal 3, player[:seat]

    player = @parser.players[2]
    assert_equal "Chris", player[:name]
    assert_equal 4, player[:seat]

    player = @parser.players[3]
    assert_equal "Dave", player[:name]
    assert_equal 5, player[:seat]

    player = @parser.players[4]
    assert_equal "Edwin", player[:name]
    assert_equal 6, player[:seat]
  end

  # extract_player_info

  test "#extract_player_info returns nil if name, id or amount is not parsed" do
    text = "Seat: tigriskem ($1.00 in chips)"
    response = @parser.extract_player_info(text)

    assert_nil response
  end

  test "#extract_player_info returns hash of player info" do
    text = "Seat 4: tigriskem ($14.69 in chips)"
    response = @parser.extract_player_info(text)

    assert_equal 4, response[:seat]
    assert_equal "tigriskem", response[:name]
    assert_equal 14.69, response[:stack]
  end

  test "#extract_player_info returns hash of player info when name has a space in it" do
    text = "Seat 4: John Smith ($14.69 in chips)"
    response = @parser.extract_player_info(text)

    assert_equal 4, response[:seat]
    assert_equal "John Smith", response[:name]
    assert_equal 14.69, response[:stack]
  end  

  test "#extract_player_info returns hash of player info when amount has no decimals" do
    text = "Seat 4: John Smith ($10 in chips)"
    response = @parser.extract_player_info(text)

    assert_equal 4, response[:seat]
    assert_equal "John Smith", response[:name]
    assert_equal 10.0, response[:stack]
  end  

  # parse_pregame

  test "#parse_pregame extracts and process blinds action" do
    @parser.parse_players
    response = @parser.parse_pregame

    small_blind = response.first
    assert_equal "small blind", small_blind[:description]
    assert_equal "posts", small_blind[:action]
    assert_equal 5, small_blind[:seat]
    
    big_blind = response.last
    assert_equal "big blind", big_blind[:description]
    assert_equal "posts", big_blind[:action]
    assert_equal 6, big_blind[:seat]
  end

  test "#parse_pregame extracts and process ante" do
    @parser = PokerHandParser::Pokerstars::HandParser.new(read_file("pokerstars/tourney_hand.txt"))
    @parser.parse_players
    response = @parser.parse_pregame
    assert_equal 8, response.select {|r| r[:description] == "the ante"}.count
    assert response.detect {|r| r[:description] == "big blind"}
    assert response.detect {|r| r[:description] == "small blind"}
  end

  # parse_actions
  test "#parse_actions on preflop with dealt cards includes deal action" do
    @parser = PokerHandParser::Pokerstars::HandParser.new(read_file("pokerstars/tourney_hand.txt"))
    @parser.parse_players
    response = @parser.parse_actions(@parser.events[:preflop])
    action = response.detect {|r| r[:action] == 'deal'}
    assert_equal 1, action[:seat]
    assert_equal "Ks", action[:cards].first
    assert_equal "5d", action[:cards].last
  end

  # parse_player_action

  test "#parse_player_action parses name with space in it" do
    @parser.parse_players
    
    entry = "Amy Adams: folds"
    action = @parser.parse_player_action(entry)

    assert_equal 2, action[:seat]
    assert_equal "folds", action[:action]
    assert_nil action[:amount]
  end

  test "#parse_player_action parses check action" do
    @parser.parse_players
    
    entry = "Billy: checks"
    action = @parser.parse_player_action(entry)

    assert_equal 3, action[:seat]
    assert_equal "checks", action[:action]
    assert_nil action[:amount]
  end

  test "#parse_player_action parses bet action" do
    @parser.parse_players
    
    entry = "Billy: bets $40"
    action = @parser.parse_player_action(entry)

    assert_equal 3, action[:seat]
    assert_equal "bets", action[:action]
    assert_equal 40.0, action[:amount]
  end

  test "#parse_player_action parses call action" do
    @parser.parse_players
    
    entry = "Billy: calls $80"
    action = @parser.parse_player_action(entry)

    assert_equal 3, action[:seat]
    assert_equal "calls", action[:action]
    assert_equal 80.0, action[:amount]
  end

  test "#parse_player_action parses call action with all-in" do
    @parser.parse_players
    
    entry = "Billy: calls 928 and is all-in"
    action = @parser.parse_player_action(entry)

    assert_equal 3, action[:seat]
    assert_equal "calls", action[:action]
    assert_equal 928.0, action[:amount]
    assert_equal true, action[:all_in] 
  end

  test "#parse_player_action parses raise action" do
    @parser.parse_players
    
    entry = "Billy: raises 1200 to 2400"
    action = @parser.parse_player_action(entry)

    assert_equal 3, action[:seat]
    assert_equal "raises", action[:action]
    assert_equal 2400.0, action[:amount]
  end

  test "#parse_player_action parses post the ante entry" do
    @parser.parse_players
    
    entry = "Billy: posts the ante 3"
    action = @parser.parse_player_action(entry)

    assert_equal 3, action[:seat]
    assert_equal "posts", action[:action]
    assert_equal 3.0, action[:amount]
    assert_equal "the ante", action[:description]
  end

  test "#parse_player_action parses post big blind entry" do
    @parser.parse_players
    
    entry = "Billy: posts small blind 25"
    action = @parser.parse_player_action(entry)

    assert_equal 3, action[:seat]
    assert_equal "posts", action[:action]
    assert_equal 25.0, action[:amount]
    assert_equal "small blind", action[:description]
  end
  
  test "#parse_player_action parses post small blind entry" do
    @parser.parse_players
    
    entry = "Billy: posts big blind 50"
    action = @parser.parse_player_action(entry)

    assert_equal 3, action[:seat]
    assert_equal "posts", action[:action]
    assert_equal 50.0, action[:amount]
    assert_equal "big blind", action[:description]
  end
  
  test "#parse_player_action raises ParseError if action is not valid" do
    @parser.parse_players
    
    entry = "Billy: does something invalid"
    assert_raises PokerHandParser::ParseError do
      action = @parser.parse_player_action(entry)
    end
  end

  # parse_system_action

  test "#parse_system_action returns disconnected hash if player is found" do
    entry = "Chris is disconnected"
    @parser.parse_players
    response = @parser.parse_system_action(entry)
    assert_equal 4, response[:seat]
    assert_equal "disconnects", response[:action]
  end

  test "#parse_system_action returns nil if invalid entry" do
    entry = "Chris says \"hello there\""
    @parser.parse_players
    assert_nil @parser.parse_system_action(entry)
  end

  # parse_deal

  test "#parse_deal returns dealt cards action hash" do
    @parser.parse_players
    response = @parser.parse_deal("[Ac Ts 5d]", "Amy Adams")

    expected = ["Ac", "Ts", "5d"]
    assert_equal expected, response[:cards]
    assert_equal 2, response[:seat]
    assert_equal 'deal', response[:action]
  end

  test "#parse_deal raises exception if entry is invalid" do
    @parser.parse_players
    assert_raises PokerHandParser::InvalidCardError do
      response = @parser.parse_deal("[Ac Ts 1c]")
    end
  end

  private

  def game_keys
    [
      :game_id, :game_name, :game_host, 
      :table_name, :table_size, 
      :button, 
      :played_at, 
      :players, 
      :actions, 
      :results, 
      :parsed_at
    ]
  end

  def action_keys
    [:deal, :preflop, :flop, :turn, :river, :showdown]  
  end

end


