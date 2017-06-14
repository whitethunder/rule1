#Consider share buybacks to screen for stocks
#Use earnings estimate revisions to predict market movements

# Regression Line
11/04 - 11/25
[1, 1163.44]
[2, 1192.25]
[3, 1195.14]
[4, 1232.16]
[5, 1251.61]
[6, 1282.39]
[7, 1298.6]
[8, 1302.14]
[9, 1302.2]
[10, 1309.48]
[11, 1315.64]
[12, 1322.23]
[13, 1342.09]
[14, 1342.09]
[15, 1347.2]

a = 12.608071428571407
B = 1179.0460952380954


12/9 - present
[[1, 1388.07],
[2, 1373.14],
[3, 1373.53],
[4, 1356.02],
[5, 1366.41],
[6, 1364.19],
[7, 1371.68],
[8, 1383.96],
[9, 1375.19],
[10, 1362.66],
[11, 1371.51],
[12, 1377.71],
[13, 1360.83],
[14, 1363.18],
[15, 1357.13],
[16, 1365.49],
[17, 1387.95],
[18, 1371.94],
[19, 1367.28],
[20, 1357.49],
[21, 1370.9],
[22, 1373.3],
[23, 1361.07],
[24, 1372.05],
[25, 1352.32],
[26, 1358.56],
[27, 1345.74],
[28, 1351.85],
[29, 1347.84],
[30, 1369.21],
[31, 1382.44],
[32, 1375.6],
[33, 1370.7],
[34, 1352.33],
[35, 1361.82],
[36, 1361.23],
[37, 1357.43],
[38, 1377.84],
[39, 1366.66],
[40, 1361.06],
[41, 1358.74],
[42, 1378.53],
[43, 1388.84],
[44, 1392.38]]
a = -0.050353770260691634
B = 1368.9465961945016

a = (n * sum(xy) - sum(x) * sum(y)) / n * sum(x^2) - (sum(x)^2)
B = (sum(y) - a * sum(x)) / n
y = ax + B

n = points.size
sumxy = points.inject(0.0) { |sum, (x,y)| sum += x * y }
sumx = points.inject(0.0) { |sum, (x,y)| sum += x }
sumy = points.inject(0.0) { |sum, (x,y)| sum += y }
sumxsq = points.inject(0.0) { |sum, (x,y)| sum += x * x }
sumallxsq = sumx * sumx
a = (n * sumxy - sumx * sumy) / (n * sumxsq - sumallxsq)
B = (sumy - a * sumx) / n
regression = points.map do |x,y|
  a * x + B
end
slope = regression[1] - regression[0]


#Standard Deviation
#https://www.mathsisfun.com/data/standard-deviation-formulas.html
require 'date'
require 'pg'
conn = PG.connect(dbname: 'buffett_development', user: 'postgres')
from_date = Date.today - 366
result = conn.exec("SELECT close FROM quotes WHERE symbol = 'RUT' AND date > '#{from_date.to_s}'")
points = result.map { |p| p["close"].to_f }
mean = points.inject(0.0) { |sum, point| sum += point } / points.size
sum_of_mean_squares = points.inject(0.0) { |sum, point| result = (point - mean) ** 2; sum += result }
standard_deviation = Math.sqrt((1.0 / points.count) * sum_of_mean_squares)


ANNUAL_TRADING_DAYS = 252 # Consider using 256 since sqrt = 16
One SD move = price * iv * sqrt(dte / ANNUAL_TRADING_DAYS)
ex: $50 stock, 30 DTE, 20% IV
one_SD = 50 * 0.2 * Math.sqrt(30 / 252) = 1.43


# Quandl API key
API_KEY = "xaBSpxEGwnu2MFV6J4rE"
require 'quandl'
Quandl::ApiConfig.api_key = API_KEY
# Quandl::ApiConfig.api_version = '2015-04-09'
data = Quandl::Dataset.get('WIKI/RUT').data(params: {start_date: '2017-05-01'})
