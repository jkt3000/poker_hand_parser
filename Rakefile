#!/usr/bin/env rake
require 'bundler'
require "bundler/gem_tasks"
require 'rake/clean'
require 'rake/testtask'

require 'pp'
require './lib/poker_hand_parser'

Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/*_test.rb'
  test.verbose = true
end


task :default => :test

desc "Import a hand history file"
task :import do 
  raise "Need FILE to run" unless file = ENV['FILE']
  puts "importing #{File.expand_path(file)}"
  
  results = PokerHandParser.parse_file(File.expand_path(file))
  puts "-"*80
  puts "Imported #{results[:hands].count} failed: #{results[:failed].count}"
  puts "-"*80
  
  pp results

  puts "-"*80
  puts "Imported #{results[:hands].count} failed: #{results[:failed].count}"
  puts "-"*80

end