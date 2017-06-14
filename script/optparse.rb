#!/home/mwhite/.rbenv/shims/ruby
require 'optparse'
require 'pp'

options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: example.rb [options]"

  opts.on("-e", "--expiration YYYYMMDD", String, "Option Expiration Date") do |v|
    options[:expiration] = v
  end

  opts.on("-s", "--symbol SYMBOL", String, "Underlying Symbol") do |v|
    options[:symbol] = v
  end

  opts.on("-t", "--strategy STRATEGY", String, "Trading Strategy") do |v|
    options[:strategy] = v
  end
end.parse!

pp options
