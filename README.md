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

TODO: Write usage instructions here

## Contributing

1. Fork it ( https://github.com/[my-github-username]/poker_hand_parser/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request


# HLD
GAME
- id
- played_at
- hero
- submitter_email
- submitter_name
- TABLE
  - host/site
  - type
  - name
  - max_size
  - players_count
  - currency
- PLAYERS
  - seat (1..10)
  - name
  - stack
- ACTIONS
  - PREFLOP
  - FLOP
  - TURN
  - RIVER
- RESULT


# sample poker hand Markup

{
  "game_id": "1234567890",
  "played_at": "2015-05-04 10:00:00",
  "table": {
    "host": "Pokerstars",
    "type": "Zoom NL Holdem ($0.25/$0.50 USD)",
    "name": "Alarmi",
    "currency": "$ ($/chips/...)",
    "max_size": 9,
    "seating": {
      "seat1": {
        "name": "johnsmith",
        "stack": 10
      },
      "seat2": {
        "name": "Frank the Tank",
        "stack": 10
      },
      "seat3": {
        "name": "KidPoker",
        "stack": 10.50
      },
      "seat4": {
        "name": "PhilLaak",
        "stack": 6.43
      }
    }
  },
  "hero": "johnsmith",
  "button": 2,
  "action": {
    "preflop": [
      { "seat1": "<ante> 0.03" },
      { "seat1": "<sb> 0.02" },
      { "seat2": "<bb> 0.03" },
      { "seat3": "<call> 0.03" },
      { "seat4": "<fold>" },
      { "seat5": "<fold>" },
      { "seat6": "<bet> 12.00" }
    ],
    "flop": [
      { "deal": "5h 4s 9d" },
      { "seat1": "<check>" },
      { "seat2": "<bet> 10.00" },
      { "seat3": "<fold>" },
      { "seat4": "<fold>" }
    ],
    "turn": [
      { "deal": "Ah" },
    ],
    "river": [
      { "deal": "Kh" }
    ],
    "showdown": [
      { "seat1": "<mucks>" },
      { "seat3": "<show> 5h 4d" },
    ]
  },
  "winners": [
    { "seat1": 12.00 },
    { "seat2": 12.00 }
  ],
  "total_pot": 111,
  "rake": 0,

  "contributor_name": "John Smith",
  "contributor_email": "john@poker.com",
  "title": "How would you play AA?",
  "description": "This is a weird hand...take a look. <markdown>"
}


# workflow

- accept input file
- split file into distinct games (double newlines == new game)
- for each game:
  - sanitize file: strip any empty newlines
  - determine game host (pokerstars, partypoker, 888, Bovada, ...)
    - use appropriate parser based on format of hand history
  - determine game type (zoom, regular, cash, tournament, NL Holdem, ...)
    - use appropriate parser based on game type 
  - extract other table metadata (max size, played_at, # of players)
  - extract seating (seat, name, stack)
  - determine bb, sb, btn
  - parse actions for preflop
    - antes
    - bb, sb
    - deal hole cards
    - player actions
  - parse actions for flop
    ...
  - parse actions for turn
  - parse actions for river
  - parse game results
  - generate JSON output
- report on success/ failure