require 'test_helper'



class PokerHandParserTest < ActiveSupport::TestCase
    
  setup do
    @file = File.join(fixture_path, "pokerstars/tourney_freerolls.txt")
  end

  # parse_file

  test "#parse_file will parse all hand histories in a given files" do
    @file = input_file("pokerstars/hands1.txt")
    results = PokerHandParser.parse_file(@file)
    assert_equal 1000, results[:hands].count
    assert_equal 0, results[:failed].count

    @file = input_file("pokerstars/hands2.txt")
    results = PokerHandParser.parse_file(@file)
    assert_equal 84, results[:hands].count
    assert_equal 0, results[:failed].count

    @file = input_file("pokerstars/tourneys.txt")
    results = PokerHandParser.parse_file(@file)
    assert_equal 20, results[:hands].count
    assert_equal 0, results[:failed].count

    @file = input_file("pokerstars/tourney_freerolls.txt")
    results = PokerHandParser.parse_file(@file)
    assert_equal 4, results[:hands].count
    assert_equal 0, results[:failed].count

  end

  test "#parse_file with invalid hand will record as an error" do
    @file = input_file("pokerstars/invalid_hand.txt")

    results = PokerHandParser.parse_file(@file)
    assert_equal 1, results[:failed].count
    assert_equal 0, results[:hands].count
  end

  # process_input_file

  test "#process_input_file returns error if file doesn't exist" do
    assert_raises StandardError do
      results = PokerHandParser.process_input_file(File.join(fixture_path, "badfile.txt"))  
    end
  end

  test "#process_input_file breaks large history file into array of hands" do
    results = PokerHandParser.process_input_file(File.join(fixture_path, "pokerstars/three_hands.txt"))
    assert_equal 3, results.count
  end
end