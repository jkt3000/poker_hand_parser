require 'json'
require 'active_support'
require "poker_hand_parser/version"


module PokerHandParser

  extend self

  # Your code goes here...
  def import(file)
    @file = file
    puts "Importing #{@file}"
    lines = File.read(@file)
    puts "#{lines.split.count} lines found"
  end

  
end
