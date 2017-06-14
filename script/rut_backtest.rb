#!/home/mwhite/.rbenv/shims/ruby
#TODO: Add guesses for probability OTM
#TODO: Normalize options data
require 'date'
# require 'dotenv'
# require 'oauth'
# require 'pg'
# require 'pp'
# require 'descriptive_statistics'
require 'rule1'
# require 'terminal-table'

symbol = ARGV[0]
start_date = ARGV[1]
connection = PG.connect(dbname: 'buffett_development', user: 'postgres')

# Go to starting date
# Move forward to next expiration Friday
# Look at option chain
# Select option that gives a minimum 48% ARORC
# "Buy" spread
# Advance to next expiration Friday
# While advancing, check Prob OTM, 3% from short strike in last week
