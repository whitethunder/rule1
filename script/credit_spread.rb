#!/home/mwhite/.rbenv/shims/ruby
#TODO: ROP and ROCC finder
#TODO: Historical Volatility and Volatility Percentile
#TODO: Switch data sources? https://www.reddit.com/r/options/comments/4wkdyl/options_pricing_data/
#TODO: Pass dividend in to calculators
require 'csv'
require 'date'
require 'dotenv'
require 'faraday'
require 'json'
require 'oauth'
require 'pg'
require 'pp'
require 'quandl'
require 'descriptive_statistics'
require 'options_library'
require 'optparse'
require 'rule1'
require 'terminal-table'

Dotenv.load

Rule1.configure do |config|
  config.endpoint = ENV["API_ENDPOINT"]
  config.consumer_key = ENV["CONSUMER_KEY"]
  config.consumer_secret = ENV["CONSUMER_SECRET"]
  config.access_token = ENV["ACCESS_TOKEN"]
  config.access_token_secret = ENV["ACCESS_TOKEN_SECRET"]
end

QUANDL_API_KEY = "xaBSpxEGwnu2MFV6J4rE"
Quandl::ApiConfig.api_key = QUANDL_API_KEY

class OptionFinder
  ANNUAL_TRADING_DAYS = 252
  OPTION_STRIKE_LOWER_BOUND = 0.50
  PERCENT_AT_RISK = 0.3
  RISK_FREE_INTEREST_RATE = 0.010
  TABLE_HEADERS = ["Strike", "Bid", "Ask", "Last", "Mark", "Volume", "%OTM", "Adjusted %OTM", "Prob OTM", "Delta", "Net Credit", "Kelly", "RORC", "ARORC"]

  attr_reader :symbol, :tradeking_symbol, :yahoo_symbol, :expiration_date

  def initialize(symbol, expiration_date)
    @symbol = symbol
    @tradeking_symbol = SymbolLookup.tradeking_symbol(symbol)
    @yahoo_symbol = SymbolLookup.yahoo_symbol(symbol)
    @expiration_date = expiration_date
    import_quotes
  end

  def bull_put_spread
    minimum_strike = quote.last * OPTION_STRIKE_LOWER_BOUND
    maximum_strike = quote.last.floor * strike_offset(:put)
    Array(expiration_date).each do |exp|
      options = Rule1::Resources::Options.get(symbol: tradeking_symbol, option_type: "put", strike_price_gte: minimum_strike, strike_price_lte: maximum_strike+1, expiration_date: exp)
      options.sort_by!(&:strike_price)
      days_to_expiration = options.first.days_to_expiration - 1

      puts "\n#{exp} BPS for #{symbol} (#{days_to_expiration})"
      puts "#{Time.now} Open: #{quote.open}  High: #{quote.high}  Low: #{quote.low}  Last: #{quote.last}  Change: #{format_percent((quote.last - last_close) / last_close)}"
      rows = []
      options.each_with_index do |option, index|
        next if index == 0
        prev = options[index-1]
        distance = ((quote.last - option.strike_price) / option.strike_price)
        adjusted_distance = distance * (45.0 / days_to_expiration)

        # standard_deviations = (quote.last - option.strike_price) / price_stdev
        # prob_otm = "%.3f" % ((1.0 - percentile(standard_deviations)) * 100)

        # stdev = quote.last * iv
        # standard_deviations = (quote.last - option.strike_price) / stdev

        # stdev = price_stdev * (1 + iv)
        # formatted_stdev = "%.3f" % stdev
        # standard_deviations = (quote.last - option.strike_price) / stdev
        # prob_otm = "%.3f" % ((1.0 - percentile(standard_deviations)) * 100)

        iv = implied_volatility(:put, quote.last, option.strike_price, days_to_expiration, option.mark)
        prob_otm = probability_otm(:put, quote.last, option.strike_price, days_to_expiration, iv)
        spread = option.strike_price - prev.strike_price
        net_credit = option.mark - prev.mark
        rorc = net_credit / spread
        multiplier = days_in_year / (option.days_to_expiration.to_f - 1)
        arorc = rorc.to_f * multiplier

        row = [
          format_spread_strikes(option, prev),
          option.bid,
          option.ask,
          format_decimal(option.last),
          format_decimal(option.mark),
          option.volume,
          format_percent(distance),
          format_percent(adjusted_distance),
          format_percent(prob_otm),
          format_decimal(delta(:put, quote.last, option.strike_price, iv, days_to_expiration)),
          format_decimal(net_credit),
          format_percent(kelly(spread, net_credit, prob_otm)),
          format_percent(rorc),
          format_percent(arorc)]
        rows << row
      end; nil

      table = Terminal::Table.new(headings: TABLE_HEADERS, rows: rows)
      puts table
    end
  end

  def bear_call_spread
    minimum_strike = quote.last.ceil * strike_offset(:call)
    maximum_strike = quote.last * (1 - OPTION_STRIKE_LOWER_BOUND + 1)
    Array(expiration_date).each do |exp|
      options = Rule1::Resources::Options.get(symbol: tradeking_symbol, option_type: "call", strike_price_gte: minimum_strike-1, strike_price_lte: maximum_strike, expiration_date: exp)
      options.sort_by!(&:strike_price)
      days_to_expiration = options.first.days_to_expiration - 1

      puts "\n#{exp} BCS for #{symbol} (#{days_to_expiration})"
      puts "#{Time.now} Open: #{quote.open}  High: #{quote.high}  Low: #{quote.low}  Last: #{quote.last}  Change: #{format_percent((quote.last - last_close) / last_close)}"
      rows = []
      options.each_with_index do |option, index|
        next if option == options.last
        prev = options[index+1]
        distance = (option.strike_price - quote.last) / option.strike_price
        adjusted_distance = distance * (45.0 / days_to_expiration)
        # standard_deviations = (quote.last - option.strike_price) / price_stdev
        # prob_otm = "%.3f" % (percentile(price_stdevs) * 100)
        iv = implied_volatility(:call, quote.last, option.strike_price, days_to_expiration, option.mark)
        prob_otm = probability_otm(:call, quote.last, option.strike_price, days_to_expiration, iv)
        spread = prev.strike_price - option.strike_price
        net_credit = option.mark - prev.mark
        rorc = net_credit / spread
        multiplier = days_in_year / (option.days_to_expiration.to_f - 1)
        arorc = rorc.to_f * multiplier

        row = [
          format_spread_strikes(option, prev),
          option.bid,
          option.ask,
          format_decimal(option.last),
          format_decimal(option.mark),
          option.volume,
          format_percent(distance),
          format_percent(adjusted_distance),
          format_percent(prob_otm),
          format_decimal(delta(:call, quote.last, option.strike_price, iv, days_to_expiration)),
          format_decimal(net_credit),
          format_percent(kelly(spread, net_credit, prob_otm)),
          format_percent(rorc),
          format_percent(arorc)]
        rows << row
      end; nil

      table = Terminal::Table.new(headings: TABLE_HEADERS, rows: rows)
      puts table
    end
  end

  def rule_one_put
    minimum_strike = quote.last * OPTION_STRIKE_LOWER_BOUND
    maximum_strike = quote.last.floor * strike_offset(:put)
    Array(expiration_date).each do |exp|
      options = Rule1::Resources::Options.get(symbol: tradeking_symbol, option_type: "put", strike_price_gte: minimum_strike, strike_price_lte: maximum_strike+1, expiration_date: exp)
      options.sort_by!(&:strike_price)
      days_to_expiration = options.first.days_to_expiration - 1

      puts "\n#{exp} ROP for #{symbol} (#{days_to_expiration})"
      puts "#{Time.now} Open: #{quote.open}  High: #{quote.high}  Low: #{quote.low}  Last: #{quote.last}  Change: #{format_percent((quote.last - last_close) / last_close)}"
      rows = []
      options.each_with_index do |option, index|
        next if index == 0
        distance = ((quote.last - option.strike_price) / option.strike_price)
        adjusted_distance = distance * (45.0 / days_to_expiration)
        iv = implied_volatility(:put, quote.last, option.strike_price, days_to_expiration, option.mark)
        prob_otm = probability_otm(:put, quote.last, option.strike_price, days_to_expiration, iv)
        net_credit = option.mark
        rorc = net_credit / quote.last
        multiplier = days_in_year / (option.days_to_expiration.to_f - 1)
        arorc = rorc.to_f * multiplier

        row = [
          format_strike(option.strike_price),
          option.bid,
          option.ask,
          format_decimal(option.last),
          format_decimal(option.mark),
          option.volume,
          format_percent(distance),
          format_percent(adjusted_distance),
          format_percent(prob_otm),
          format_decimal(delta(:put, quote.last, option.strike_price, iv, days_to_expiration)),
          format_decimal(net_credit),
          format_percent(kelly(quote.last, net_credit, prob_otm)),
          format_percent(rorc),
          format_percent(arorc)]
        rows << row
      end; nil

      table = Terminal::Table.new(headings: TABLE_HEADERS, rows: rows)
      puts table
    end
  end

  def rule_one_covered_call
    minimum_strike = quote.last.ceil * strike_offset(:call)
    maximum_strike = quote.last * (1 - OPTION_STRIKE_LOWER_BOUND + 1)
    Array(expiration_date).each do |exp|
      options = Rule1::Resources::Options.get(symbol: tradeking_symbol, option_type: "call", strike_price_gte: minimum_strike-1, strike_price_lte: maximum_strike, expiration_date: exp)
      options.sort_by!(&:strike_price)
      days_to_expiration = options.first.days_to_expiration - 1

      puts "\n#{exp} ROCC for #{symbol} (#{days_to_expiration})"
      puts "#{Time.now} Open: #{quote.open}  High: #{quote.high}  Low: #{quote.low}  Last: #{quote.last}  Change: #{format_percent((quote.last - last_close) / last_close)}"
      rows = []
      options.each_with_index do |option, index|
        next if index == 0
        prev = options[index-1]
        distance = (option.strike_price - quote.last) / option.strike_price
        adjusted_distance = distance * (45.0 / days_to_expiration)
        iv = implied_volatility(:call, quote.last, option.strike_price, days_to_expiration, option.mark)
        prob_otm = probability_otm(:call, quote.last, option.strike_price, days_to_expiration, iv)
        net_credit = option.mark
        rorc = net_credit / quote.last
        multiplier = days_in_year / (option.days_to_expiration.to_f - 1)
        arorc = rorc.to_f * multiplier

        row = [
          format_strike(option.strike_price),
          option.bid,
          option.ask,
          format_decimal(option.last),
          format_decimal(option.mark),
          option.volume,
          format_percent(distance),
          format_percent(adjusted_distance),
          format_percent(prob_otm),
          format_decimal(delta(:call, quote.last, option.strike_price, iv, days_to_expiration)),
          format_decimal(net_credit),
          format_percent(kelly(quote.last, net_credit, prob_otm)),
          format_percent(rorc),
          format_percent(arorc)]
        rows << row
      end; nil

      table = Terminal::Table.new(headings: TABLE_HEADERS, rows: rows)
      puts table
    end
  end

  private

  def quote
    @quote ||= Rule1::Resources::Quotes.get(tradeking_symbol).first
  end

  def closing_prices(days=days_in_year)
    @closing_prices ||= begin
      result = connection.exec("SELECT * FROM quotes WHERE symbol = '#{symbol}' AND date >= '#{Date.today - days}' ORDER BY date ASC")
      result.map { |r| r["close"].to_f }
    end
  end

  def last_close
    closing_prices.last
  end

  def daily_ln_returns(days=days_in_year)
    closing_prices(days).each_cons(2).map { |cons| Math.log(cons.last / cons.first) }
  end

  def historic_volatility
    daily_ln_returns.standard_deviation * Math.sqrt(ANNUAL_TRADING_DAYS)
  end

  def price_stdev
    @price_stdev ||= closing_prices.standard_deviation
  end

  def implied_volatility(type, last_price, strike_price, dte, mark, dividend=0.0)
    option = Module.const_get("Option::#{type.to_s.capitalize}").new
    option.underlying = last_price
    option.strike = strike_price
    option.time = dte / days_in_year.to_f
    option.interest = RISK_FREE_INTEREST_RATE
    option.sigma = historic_volatility
    option.dividend = dividend
    option.calc_implied_vol(mark)
  end

  def delta(type, last_price, strike_price, iv, dte, dividend=0.0)
    option = Module.const_get("Option::#{type.to_s.capitalize}").new
    option.underlying = last_price
    option.strike = strike_price
    option.time = dte / days_in_year.to_f
    option.interest = RISK_FREE_INTEREST_RATE
    option.sigma = iv
    option.dividend = dividend
    option.calc_delta
  end

  def probability_otm(type, last_price, strike_price, dte, implied_vol)
    annualized_volatility = implied_vol * Math.sqrt(dte / days_in_year.to_f)
    lnpq = Math.log(strike_price / last_price)
    d1 = lnpq / annualized_volatility

    y = (1 / (1 + 0.2316419 * d1.abs) * 100000).floor / 100000.0
    z = (0.3989423 * Math.exp(-((d1 * d1) / 2)) * 100000).floor / 100000.0
    y5 = 1.330274 * (y ** 5)
    y4 = 1.821256 * (y ** 4)
    y3 = 1.781478 * (y ** 3)
    y2 = 0.356538 * (y ** 2)
    y1 = 0.3193815 * y
    x = 1 - z * (y5 - y4 + y3 - y2 + y1)
    x = (x * 100000).floor / 100000.0

    x = 1 - x if d1 < 0

    type == :put ? 1 - x : x
  end

  def kelly(spread, net_credit, prob_otm)
    risk_capital = spread - net_credit
    average_loss = risk_capital * PERCENT_AT_RISK
    r = net_credit / average_loss
    k = prob_otm - (1 - prob_otm) / r
    k < 0 ? 0 : k
  end

  def days_in_year
    @days_in_year ||= Date.gregorian_leap?(Date.today.year) ? 366 : 365
  end

  def strike_offset(option_type)
    if [
      "RUT",
      "SPX"
    ].include?(symbol)
      1.0
    else
      if option_type == :put
        1.03
      else
        0.97
      end
    end
  end

  def format_decimal(number)
    "%.2f" % number
  end

  def format_percent(number)
    "#{format_decimal(number * 100)}%"
  end

  def format_spread_strikes(opt1, opt2)
    "#{format_strike(opt1.strike_price)}/#{format_strike(opt2.strike_price)}"
  end

  def format_strike(strike)
    Integer(strike) == strike ? Integer(strike) : strike
  end

  def percentile(z)
    return 0 if z < -6.5
    return 1 if z > 6.5

    factk = 1
    sum = 0
    term = 1
    k = 0

    loop_stop = Math.exp(-23)
    while term.abs > loop_stop do
        term = 0.3989422804 * ((-1)**k) * (z**k) / (2*k+1) / (2**k) * (z**(k+1)) / factk
        sum += term
        k += 1
        factk *= k
    end

    sum += 0.5
    1-sum
  end

  def import_quotes
    last_date = connection.exec("SELECT MAX(date) FROM quotes WHERE symbol = '#{symbol}'").first["max"]
    to_date = Time.now.hour >= 16 ? Date.today : (Date.today - 1)
    to_date -= 1 if to_date.wday == 0
    to_date -= 1 if to_date.wday == 6
    if last_date.nil?
      from_date = Date.today - days_in_year
    else
      from_date = Date.parse(last_date) + 1
      return if from_date > to_date
    end

    if SymbolLookup.yahoo_symbol(symbol)
      response = Faraday.get(URI.encode("https://finance.yahoo.com/quote/#{SymbolLookup.yahoo_symbol(symbol)}/history?p=#{SymbolLookup.yahoo_symbol(symbol)}"))
      json = response.body[/"prices":([^\]]+\])/, 1]
      prices = JSON.parse(json)
      prices.each { |p| p["date"] = Time.at(p["date"]).to_date }
      prices.sort_by { |p| p["date"] }.select { |p| (from_date..to_date).cover?(p["date"]) }.each do |quote|
        connection.exec("INSERT INTO quotes(symbol, date, open, high, low, close, volume) VALUES('#{symbol.sub('^', '')}', '#{quote['date'].to_s}', %.4f, %.4f, %.4f, %.4f, %d)" % quote.values_at("open", "high", "low", "close", "volume"))
      end
    else
      data = Quandl::Dataset.get("WIKI/#{symbol}").data(params: { start_date: from_date.to_s, end_date: to_date.to_s })
      data.sort_by(&:date).each do |quote|
        connection.exec("INSERT INTO quotes(symbol, date, open, high, low, close, volume) VALUES('#{symbol.sub('^', '')}', '#{quote.date.to_s}', %.4f, %.4f, %.4f, %.4f, %d)" % quote.values_at("open", "high", "low", "close", "volume"))
      end
    end
  end

  def connection
    @connection ||= PG.connect(dbname: 'buffett_development', user: 'postgres')
  end
end

module SymbolLookup
  extend self

  def tradeking_symbol(symbol)
    case symbol
    when "BRK_B"
      "BRK'B"
    else
      symbol
    end
  end

  def yahoo_symbol(symbol)
    case symbol
    when "SPX"
      "^GSPC"
    when "RUT"
      "^RUT"
    else
      nil
    end
  end
end


options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: credit_spread.rb [options]"

  opts.on("-d", "--max_days_to_expiration DD", Integer, "Maximum Days to Expiration") do |v|
    options[:max_dte] = v
  end

  opts.on("-m", "--min_days_to_expiration DD", Integer, "Minimum Days to Expiration") do |v|
    options[:min_dte] = v
  end

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

if options[:expiration].nil?
  options[:expiration] = Rule1::Resources::Options.expirations(SymbolLookup.tradeking_symbol(options[:symbol])).map(&:api_formatted)
  options[:expiration].delete_if { |exp| exp.to_i > (Date.today + options[:max_dte].to_i).strftime("%Y%m%d").to_i } if options[:max_dte]
  options[:expiration].delete_if { |exp| exp.to_i < (Date.today + options[:min_dte].to_i).strftime("%Y%m%d").to_i } if options[:min_dte]
end

finder = OptionFinder.new(options[:symbol], options[:expiration])

case options[:strategy]&.downcase
when "bps"
  finder.bull_put_spread
when "bcs"
  finder.bear_call_spread
when "rop"
  finder.rule_one_put
when "rocc"
  finder.rule_one_covered_call
else
  finder.bull_put_spread
end

# symbols = ["WFM", "BWLD", "RUT", "UA", "AAPL"].sort
