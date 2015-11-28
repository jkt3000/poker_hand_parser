require 'json'
require 'active_support'
require "poker_parser/version"


module PokerParser

  extend self

  def import(file)
    @file = file
    puts "Importing #{@file}"
    lines = File.read(@file)
    puts "#{lines.split.count} lines found"
  end
  # Your code goes here...
end
