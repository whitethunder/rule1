# CREATE DATABASE financial_data;
# psql financial_data postgres
CREATE TABLE quotes(
  id SERIAL PRIMARY KEY,
  symbol VARCHAR(32),
  date DATE,
  open DECIMAL(11,4),
  high DECIMAL(11,4),
  low DECIMAL(11,4),
  close DECIMAL(11,4),
  volume INTEGER);
CREATE INDEX quotes_date_key ON quotes(date);
CREATE UNIQUE INDEX quotes_symbol_date ON quotes(symbol, date);

CREATE TABLE options(
  id SERIAL PRIMARY KEY,
  symbol VARCHAR(32),
  strike DECIMAL(11,4),
  date DATE,
  bid DECIMAL(11,4),
  ask DECIMAL(11,4),
  mark DECIMAL(11,4),
  probability_otm DECIMAL(5,4),
  delta DECIMAL(11,4),
  days_to_expiration INTEGER,
  expiration_date DATE,
  expiration_type VARCHAR(32),
  type VARCHAR(32));
CREATE UNIQUE INDEX options_symbol_date_strike_type_expiration_date_unique_index ON options(symbol, date, strike, type, expiration_date);
CREATE INDEX options_date_key ON options(date);
CREATE INDEX options_expiration_date_key ON options(expiration_date);
