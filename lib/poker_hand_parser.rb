require 'json'
require 'active_support'
require 'time'
require "poker_hand_parser/version"
require "poker_hand_parser/cards"
require "poker_hand_parser/pokerstars/hand_parser"

module PokerHandParser

  extend self

  def parse_file(file)
    hand_histories = process_input_file(file)

    results = { hands: [], failed: [] }
    hand_histories.inject(results) do |results, hand|
      game = parse_hand(hand)
      key = game.key?(:game_id) ? :hands : :failed
      results[key] << game
      results
    end
    results
  end

  def parse_hand(hand)
    parser_model = detect_parser_type(hand)
    parser       = parser_model.new(hand)
    parser.parse
  rescue StandardError => e
    logger.debug("[Parse Hand] Error: #{e} #{e.backtrace[0]}")
    logger.debug("Hand content:\n#{hand}")
    {
      error: "#{e} #{e.backtrace[0]}",
      hand: hand
    }
  end

  def process_input_file(file)
    raise StandardError, "File not found or invalid" unless File.exists?(file)
    contents = File.read(file)
    contents = contents.gsub(/\r\n?/, "\n")
    contents = contents.gsub(/\r/, "\n")
    hands = contents.split(/^$\n{3}/)
    hands = hands.map do |hand|
      next if hand.blank?
      hand
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
  class InvalidHandHistoryError < StandardError; end
end
