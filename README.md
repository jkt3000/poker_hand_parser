# PokerHandParser

PokerHandParser is a ruby gem that parses poker hand histories and converts them into Poker Markup Language (PML), a very basic JSON-based format.

The following poker hand histories can be imported:
- pokerstars
- others coming soon

Take in a hand history file in text format.
For each valid hand found, produces JSON text of the hand


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'poker_hand_parser'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install poker_hand_parser

## Usage

To use,

```ruby
  results = PokerHandParser.parse_file(file)
```

will return a hash of :hands and :failed. An example output is shown below.


There is a rake task you can run to manually test via command line a hand history file.

    $ rake parse FILE=<name of file>

This will run the parser and attempt to parse the file if it can find it. Once finished parsing,
it will spit out output of the # of hands imported, # of hands failed, and a prettyprint output of the entire results hash (this could be very big depending on the number of hands your hand history file contains)

For example:

    rake parse FILE=test/fixtures/pokerstars/hand1.txt
    Parsing /Users/t/projects/poker_hand_parser/test/fixtures/pokerstars/hand1.txt
    --------------------------------------------------------------------------------
    Parsed 1 failed: 0
    --------------------------------------------------------------------------------
    {:hands=>
      [{:game_id=>"59950643732",
        :game_host=>"Pokerstars",
        :game_name=>"Hold'em No Limit ($5/$10)",
        :table_name=>"AlphaTable",
        :table_size=>6,
        :button=>4,
        :played_at=>2009-07-01 06:57:14 -0400,
        :players=>
         [{:name=>"Amy Adams", :seat=>2, :stack=>591.0},
          {:name=>"Billy", :seat=>3, :stack=>439.0},
          {:name=>"Chris", :seat=>4, :stack=>354.1},
          {:name=>"Dave", :seat=>5, :stack=>834.45},
          {:name=>"Edwin", :seat=>6, :stack=>275.0}],
        :actions=>
         {:deal=>
           [{:seat=>5,
             :action=>"posts",
             :amount=>5.0,
             :description=>"small blind"},
            {:seat=>6,
             :action=>"posts",
             :amount=>10.0,
             :description=>"big blind"}],
          :preflop=>
           [{:seat=>2, :action=>"calls", :amount=>10.0},
            {:seat=>3, :action=>"folds", :amount=>nil},
            {:seat=>4, :action=>"folds", :amount=>nil},
            {:seat=>5, :action=>"folds", :amount=>nil},
            {:seat=>6, :action=>"checks", :amount=>nil}],
          :flop=>
           [{:seat=>nil, :action=>"deal", :cards=>["6h", "7s", "5h"]},
            {:seat=>6, :action=>"bets", :amount=>20.0},
            {:seat=>2, :action=>"calls", :amount=>20.0}],
          :turn=>
           [{:seat=>nil, :action=>"deal", :cards=>["6h", "7s", "5h", "3s"]},
            {:seat=>6, :action=>"checks", :amount=>nil},
            {:seat=>2, :action=>"checks", :amount=>nil}],
          :river=>
           [{:seat=>nil, :action=>"deal", :cards=>["6h", "7s", "5h", "3s", "Td"]},
            {:seat=>6, :action=>"bets", :amount=>40.0},
            {:seat=>2, :action=>"raises", :amount=>120.0},
            {:seat=>6, :action=>"calls", :amount=>80.0}],
          :showdown=>
           [{:seat=>2,
             :action=>"shows",
             :amount=>nil,
             :description=>"straight, Three to Seven",
             :cards=>["Qh", "4c"]},
            {:seat=>6,
             :action=>"shows",
             :amount=>nil,
             :description=>"straight, Three to Seven",
             :cards=>["7d", "4s"]},
            {:seat=>6, :action=>"collected", :amount=>151.5},
            {:seat=>2, :action=>"collected", :amount=>151.5}]},
        :results=>{:total_pot=>305.0, :rake=>2.0},
        :parsed_at=>2015-12-03 02:23:01 UTC}],
     :failed=>[]}
    --------------------------------------------------------------------------------
    Parsed 1 failed: 0
    --------------------------------------------------------------------------------

## Contributing

1. Fork it ( https://github.com/[my-github-username]/poker_hand_parser/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

