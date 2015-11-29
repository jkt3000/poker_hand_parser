require 'json'
require 'active_support'
require "poker_hand_parser/version"
require 'poker_hand_parser/game'
require 'poker_hand_parser/table'
require 'poker_hand_parser/player'
require "poker_hand_parser/pokerstars/parser"

module PokerHandParser

  extend self

  def import_from_file(filehandle)
    # handles splitting file into games
    # determine which parser to use
    # for each game history,
      # parse history
    # builds hash of parsed hands, # failed
  end

  def game_histories

  end

  def parse_game(game)
    # returns json of parsed game and error message
    # if successful,
      # returns <json>, status: ok
    # if failed
      # returns nil, status: failed, message: .....
  end

  # Your code goes here...
  def import(file)
    @file = file
    puts "Importing #{@file}"
    lines = File.read(@file)
    puts "#{lines.split.count} lines found"
  end

  
end
