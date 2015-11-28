require 'test_helper'

class PlayerTest < ActiveSupport::TestCase
    
  setup do
    @options = {
      name: "John Smith",
      seat: 2,
      stack: 10.00
    }
  end

  test "create a player object" do
    @player = PokerHandParser::Player.new(@options)
    assert @player.is_a?(PokerHandParser::Player)
    assert_equal @options[:name], @player.name
    assert_equal @options[:seat], @player.seat
    assert_equal @options[:stack], @player.stack    
  end

  test "to_json generates json of player attributes" do
    @player = PokerHandParser::Player.new(@options)
    resp = @player.to_json
    hash = JSON.parse(resp)

    assert_equal 3, hash.keys.count
    assert hash.key?("name")
    assert hash.key?("seat")
    assert hash.key?("stack")
  end
end