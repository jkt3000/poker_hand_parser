require 'test_helper'



class PokerHandParserTest < ActiveSupport::TestCase
    
  setup do
    @file = File.join(fixture_path, "pokerstars/tourney_freerolls.txt")
  end

  # parse_file

  test "#parse_file will parse all hand histories in a given file" do
    @file = input_file("pokerstars/hands1.txt")

    PokerHandParser.expects(:parse_hand).at_least_once.returns({})
    results = PokerHandParser.parse_file(@file)

    assert results[:hands].count > 1
    assert results[:failed].empty?
  end

  test "#parse_file with invalid hand will record as an error" do
    @file = input_file("pokerstars/hands1.txt")

    PokerHandParser.expects(:parse_hand).at_least_once.returns(nil)
    results = PokerHandParser.parse_file(@file)

    assert results[:failed].count > 1
    assert results[:failed].first.include?("PokerStars Game")
  end

  test "#parse_file with :json => true returns response in JSON format" do
  end

  # process_input_file

  test "#process_input_file returns error if file doesn't exist" do
    assert_raises StandardError do
      results = PokerHandParser.process_input_file(File.join(fixture_path, "badfile.txt"))  
    end
  end

  test "#process_input_file returns array of entries that are separated by 3 line breaks" do
    results = PokerHandParser.process_input_file(@file)
    assert_equal 4, results.count

    results.all? {|r| refute r.blank? }
    results.all? {|r| refute r.start_with?("\n") }
  end

  test "#process_input_file removes blank lines between data, but keeps as single hand history" do
    results = PokerHandParser.process_input_file(File.join(fixture_path, "sample_input.txt"))
    assert_equal 2, results.count
    refute results.first.match(/\n{2,}/)
    refute results.last.match(/\n{2,}/)
  end
end