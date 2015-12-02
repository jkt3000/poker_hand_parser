require 'json'
require 'active_support'
require 'time'
require "poker_hand_parser/version"
require "poker_hand_parser/cards"
require 'poker_hand_parser/game'
require 'poker_hand_parser/table'
require 'poker_hand_parser/player'
require 'poker_hand_parser/hand_parser'
require "poker_hand_parser/pokerstars/hand_parser"

module PokerHandParser

  extend self

  def parse_file(file, json: false)
    hand_histories = process_input_file(file)

    results = { hands: [], failed: [] }
    hand_histories.inject(results) do |results, hand|
      if game = parse_hand(hand)
        results[:hands] << game
      else
        results[:failed] << hand
      end
      results
    end
    json ? results.to_json : results
  end

  # parses a single hand history and returns hash of hand or nil if fails
  def parse_hand(hand)
    parser_model = detect_parser_type(hand)
    parser       = parser_model.new(hand)
    parser.parse
  end

  def process_input_file(file)
    raise StandardError, "File not found or invalid" unless File.exists?(file)
    contents = File.read(file)
    hands = contents.split(/^$\n{3}|(\r\n){3}/)
    hands = hands.map do |hand|
      hand.gsub(/^$\n|\r\n/, '')
    end.compact
    hands.reject(&:blank?)
  end

  # future - return the proper parser type
  def detect_parser_type(hands)
    PokerHandParser::Pokerstars::HandParser
  end

  def logger=(logger)
    @@logger = logger
  end

  def logger
    @@logger
  end

  @@logger = Logger.new(STDOUT)
  @@logger.level = Logger::INFO

  class NotImplementedError < StandardError; end
  class ParseError < StandardError; end
end
