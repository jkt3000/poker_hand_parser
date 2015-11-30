require 'json'
require 'active_support'
require 'time'
require "poker_hand_parser/version"
require 'poker_hand_parser/game'
require 'poker_hand_parser/table'
require 'poker_hand_parser/player'
require 'poker_hand_parser/hand_parser'
require "poker_hand_parser/pokerstars/hand_parser"

module PokerHandParser

  RESULTS = {
    hands: [],
    errors: [],
    parsed: 0,
    failed: 0
  }.freeze

  extend self

  # parses input fiile and returns hash of results
  def parse(filehandle, json: false)
    results         = RESULTS.dup
    sanitized_games = process_input_file(filehandle)
    hand_parser     = detect_parser_type(sanitized_games)

    sanitized_games.inject(RESULTS.dup) do |results, hand|
      game = hand_parser.process_game(hand)
      if game.parsed?
        results[:hands] << game.to_hash
      else
        results[:errors] << game.errors
      end
      results
    end
    results[:parsed] = results[:hands].count
    results[:failed] = results[:errors].count
    results
    # convert to json format if json is set to true
  end

  # returns hash of processed hand
  def process_game(history)
    # determine host game (pokerstars, etc...)
    # initialize proper parser
  end

  def process_input_file(file)
    # split file into array of game logs
  end

  def detect_parser_type(hands)
    # determine type of parser based on format of file
  end


  class NotImplementedError < StandardError; end

end
