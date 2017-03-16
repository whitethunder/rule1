require 'csv'
require 'date'
require 'pg'

ROOT_PATH = "/home/mwhite/Downloads/Rule1/TOSData/"
RAW_DATA_PATH = ROOT_PATH + "raw_data/"


# Check for file date mismatch
files = Dir[File.join(RAW_DATA_PATH, "*")]
files.each do |path|
  print "Verifying #{path} ... "
  contents = File.read(path)
  file_date = path[/(\d{4}-\d{2}-\d{2})/, 1]
  file_date = Date.parse(file_date)
  american_date = file_date.strftime("%-m/%-d/%y")
  export_date = contents[/Stock quote and option quote for RUT on ([^\s]+)/, 1]
  if american_date == export_date
    puts "Verified."
  else
    puts "#{path} is corrupt."
    exit(0)
  end
end


# Remove market holidays
# http://www.tradingtheodds.com/nyse-full-day-closings/
dates = File.read(File.join(ROOT_PATH, "market_holidays.txt"))
dates = dates.split("\n")
dates.map! { |d| "RUTOptions-#{Date.parse(d).strftime('%Y-%m-%d')}.csv" }
dates.each do |filename|
  full_path = File.join(RAW_DATA_PATH, filename)
  File.unlink(full_path) if File.exists?(full_path)
end


# Replace occurances of <empty> with 0
find . -type f -exec sed -i 's/<empty>/0/g' {} +


# Import TOS files
def convert_percentage(str)
  str.sub!("%", "")
  str.to_f * 0.01
end

files = Dir[File.join(RAW_DATA_PATH, "*")].sort; nil
files.select! { |f| File.file?(f) }; nil
files.sort_by! { |f| Date.parse(f[/(\d{4}-\d{2}-\d{2}).csv$/, 1]) }; nil
files.select! { |f| date = Date.parse(f[/(\d{4}-\d{2}-\d{2}).csv$/, 1]); date >= Date.parse('2014-06-30') }; nil
conn = PG.connect(dbname: 'buffett_development', user: 'postgres')
symbol = "RUT"
files.each do |path|
  print "Importing #{path} ... "
  file_date = path[/(\d{4}-\d{2}-\d{2})/, 1]
  contents = File.read(path)

  #Import stock quote
  quote_section = contents[/UNDERLYING\n(.+?\n.+?\n)/, 1]
  csv = CSV.parse(quote_section, headers: true)
  quote = csv.first
  conn.exec("INSERT INTO quotes(symbol, date, open, high, low, close, volume) VALUES('#{symbol}', '#{file_date}', %.4f, %.4f, %.4f, %.4f, %d)" % quote.values_at("Open", "High", "Low", "Last", "Volume"))

  #Import option chains
  contents.scan(/(\d+\s\w{3}\s\d{2})\s+\((\d+)\).+?(?:[^(]+\(([^)]+)\))?\n(.+?)\n$/m) do |expiration, dte, expiration_type, option|
    expiration_type = "Monthlys" if expiration_type.nil? || expiration_type.empty?
    option.sub!(",,Mark,Prob.OTM,Delta,Mark,Bid,Ask,Exp,Strike,Bid,Ask,Mark,Prob.OTM,Delta,Mark,,", ",,Call Mark,Call Prob.OTM,Call Delta,Call Mark,Call Bid,Call Ask,Call Exp,Strike,Put Bid,Put Ask,Put Mark,Put Prob.OTM,Put Delta,Put Mark,,")
    # puts expiration
    # puts dte
    # puts expiration_type
    # puts option[0..100]
    # puts option
    csv = CSV.parse(option, headers: true)
    csv.each do |row|
      begin
        expiration = Date.parse(expiration).strftime("%Y-%m-%d")
        cpotm = convert_percentage(row["Call Prob.OTM"])
        conn.exec("INSERT INTO options(symbol,      date,           strike, bid,  ask,  mark, probability_otm,    delta, days_to_expiration, expiration_date, expiration_type,                    type)
                                VALUES('#{symbol}', '#{file_date}', %.4f,   %.4f, %.4f, %.4f, #{cpotm},           %.3f,  #{dte},             '#{expiration}', '#{expiration_type.downcase.chop}', 'call')" %
                                row.values_at("Strike", "Call Bid", "Call Ask", "Call Mark", "Call Delta"))
        ppotm = convert_percentage(row["Put Prob.OTM"])
        conn.exec("INSERT INTO options(symbol,      date,           strike, bid,  ask,  mark, probability_otm,    delta, days_to_expiration, expiration_date, expiration_type,                    type)
                                VALUES('#{symbol}', '#{file_date}', %.4f,   %.4f, %.4f, %.4f, #{ppotm},           %.3f,  #{dte},             '#{expiration}', '#{expiration_type.downcase.chop}', 'put')" %
                                row.values_at("Strike", "Put Bid", "Put Ask", "Put Mark", "Put Delta"))
      # rescue PG::UniqueViolation
      #   puts "rescued"
      end
    end
  end; nil

  puts "Done."
end


#Import quotes from Yahoo Finance
require 'csv'
require 'date'
require 'faraday'
require 'pg'
conn = PG.connect(dbname: 'financial_data', user: 'postgres')
symbol = "RUT"
yahoo_symbol = "^RUT"
from_date = conn.exec("SELECT MAX(date) FROM quotes WHERE symbol = '#{symbol}'").first["max"]
from_date = Date.parse(from_date) + 1
to_date = Time.now.hour >= 16 ? Date.today : (Date.today - 1)
response = Faraday.get("http://chart.finance.yahoo.com/table.csv?s=#{yahoo_symbol}&a=#{from_date.strftime('%-m').to_i-1}&b=#{from_date.strftime('%-d')}&c=#{from_date.strftime('%Y')}&d=#{to_date.strftime('%-m').to_i-1}&e=#{to_date.strftime('%-d')}&f=#{to_date.strftime('%Y')}&g=d&ignore=.csv"); nil
quotes = CSV.parse(response.body, headers: true)
quotes.reverse_each do |quote|
  conn.exec("INSERT INTO quotes(symbol, date, open, high, low, close, volume) VALUES('#{symbol.sub('^', '')}', '#{quote['Date']}', %.4f, %.4f, %.4f, %.4f, %d)" % quote.values_at("Open", "High", "Low", "Close", "Volume"))
end; nil
