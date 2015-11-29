require 'test_helper'

class TableTest < ActiveSupport::TestCase
    
  setup do
    @player1 = { name: "AllanA", seat: 1, stack: 10.00 }
    @player2 = { name: "BillyB", seat: 2, stack: 10.00 }
    @player3 = { name: "ChrisC", seat: 3, stack: 10.00 }
    @player4 = { name: "DenisD", seat: 4, stack: 10.00 }
    @player5 = { name: "EricaE", seat: 5, stack: 10.00 }
    @params = {
      name: 'Test Table',
      host: "pokerstars",
      type: "Zoom NL Holdem ($0.02/$0.05)",
      currency: 0.05,
      max_size: 9
    }
    @table = PokerHandParser::Table.new(@params)
  end

  # create

  test "#create a table with no players" do
    @table = PokerHandParser::Table.new(@params)

    assert_equal @params[:name], @table.name
    assert_equal @params[:host], @table.host
    assert_equal @params[:type], @table.type
    assert_equal @params[:currency], @table.currency    
    assert_equal @params[:max_size], @table.max_size
    assert @table.players.empty?
  end

  test "#create a table with players" do
    @players = [
      PokerHandParser::Player.new(@player1),
      PokerHandParser::Player.new(@player2)
    ]

    @table = PokerHandParser::Table.new(@params.merge(players: @players))
    assert_equal @players.count, @table.players.count
  end

  # add_player

  test "#add_player with an instance of Player to a table" do
    assert_difference "@table.players.count", 1 do
      assert @table.add_player(@player1)    
    end
    assert @table.seat(1).is_a?(PokerHandParser::Player)
  end

  test "#add_player with hash of player attributes to a table" do
    @player = PokerHandParser::Player.new(@player1)
    assert_difference "@table.players.count", 1 do
      assert @table.add_player(@player)    
    end
    assert @table.seat(1).is_a?(PokerHandParser::Player)
    assert_equal "AllanA", @table.seat(1).name
  end

  # seating_map

  test "#seating_map returns hash of seat mapping" do
    assert_difference "@table.players.count", 5 do
      assert @table.add_player(@player5)
      assert @table.add_player(@player3)
      assert @table.add_player(@player2)
      assert @table.add_player(@player1)
    end
    
    map = @table.seating_map

    assert_equal @player1, map[:seat1].to_hash
    assert_equal @player2, map[:seat2].to_hash
    assert_equal @player3, map[:seat3].to_hash
    assert_nil map[:seat4]
    assert_equal @player5, map[:seat5].to_hash
    assert_nil map[:seat6]
    assert_nil map[:seat7]
    assert_nil map[:seat8]
    assert_nil map[:seat9]
  end

  # seat
 
  test "#seat() returns player in given seat" do
    assert @table.add_player(@player5)
    assert @table.seat(5).is_a?(PokerHandParser::Player)
  end

  test "#seat() returns nil if no player exists in that seat" do
    assert_nil @table.seat(5)
  end

  test "#seat() returns nil if seat is less than 1 or greater than max seats" do
    assert_nil @table.seat(0)
    assert_nil @table.seat(11)
  end

  # to_json

  test "#to_json return table data in json format" do
    assert @table.add_player(@player1)
    assert @table.add_player(@player2)
    assert @table.add_player(@player5)
    result = @table.to_json
    hash = JSON.parse(result)
    assert_equal json_result, JSON.parse(result)
  end

  def json_result
    {
      "name" => "Test Table",
      "host" => "pokerstars",
      "type" => "Zoom NL Holdem ($0.02/$0.05)",
      "currency" => 0.05,
      "max_size" => 9,
      "players" => [
        { "name" => "AllanA","seat" => 1,"stack" => 10.0 },
        { "name" => "BillyB","seat" => 2,"stack" => 10.0 },
        { "name" => "EricaE","seat" => 5,"stack" => 10.0 },
      ]
    }
  end

end