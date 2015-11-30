require 'test_helper'

class PokerHandParser::Pokerstars::HandParserTest < ActiveSupport::TestCase

  setup do
    @parser = PokerHandParser::Pokerstars::HandParser.new(read_file("ps_single_hand1.txt"))
  end

  # create

  test "#create instance of Pokerstars::HandParser breaks raw events into categories" do
    @parser = PokerHandParser::Pokerstars::HandParser.new(read_file("ps_single_hand1.txt"))
    assert @parser.events[:settings].present?
    assert @parser.events[:preflop].present?
    assert @parser.events[:flop].present?
    assert @parser.events[:turn].present?
    assert @parser.events[:river].present?
    assert @parser.events[:summary].present?
  end

  test "#create breaks events into categories when missing some events" do
    @parser = PokerHandParser::Pokerstars::HandParser.new(read_file("ps_single_hand2.txt"))
    assert @parser.events[:settings].present?
    assert @parser.events[:preflop].present?
    assert @parser.events[:flop].blank?
    assert @parser.events[:turn].blank?
    assert @parser.events[:river].blank?
    assert @parser.events[:summary].present?
  end

  # parse_game_details

  test "#parse_game_details extracts parameters for cash game" do
    @parser = PokerHandParser::Pokerstars::HandParser.new(read_file("ps_single_hand1.txt"))
    @parser.parse_game_details
    @game = @parser.game_details
    assert_equal "59950643732", @game[:game_id]
    assert_equal "Hold'em No Limit ($5/$10)", @game[:game_name]
    assert_equal "Pokerstars", @game[:game_host]
    assert_equal Time.parse("2009/07/01 6:57:14 ET"), @game[:played_at]
    assert_equal 6, @game[:table_size]
    assert_equal "ZemUU8uyOTYQAgqnaWQDUA", @game[:table_name]
    assert_equal 4, @game[:button]
  end

  test "#parse_game_details extracts parameters for tournament game" do
    @parser = PokerHandParser::Pokerstars::HandParser.new(read_file("ps_single_hand_tourney.txt"))
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
    assert_equal [2,3,4,5,6], @parser.players.map {|x| x[:seat] }.sort
  end

  # parse_preflop

  # parse_flop

  # parse_turn

  # parse_river

  # parse_showdown

  # parse_summary

end


