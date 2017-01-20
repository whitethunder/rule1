class Rule1::Option < Model
  property :symbol, from: :rootsymbol
  property :last, coerce: Float
  property :strike_price, from: :strikeprice, coerce: Float
  property :days_to_expiration, coerce: Integer
  property :subclass, from: :op_subclass
  property :open_interest, from: :pr_openinterest
  property :volume, from: :vl, coerce: Integer

  def risk_capital
    strike_price - last
  end

  def rorc
    last / risk_capital
  end

  def multiplier
    365.0 / days_to_expiration
  end

  def arorc
    rorc * multiplier
  end

  def to_s
    string = "Strike: #{strike_price}\n"
    string << "Volume: #{volume}\n"
    string << "ARORC: "
    string << "%.2f" % "#{arorc * 100}"
    string << "%"
  end
end
