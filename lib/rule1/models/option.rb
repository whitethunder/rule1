module Rule1
  module Models
    class Option < Model
      autoload :Expiration, "rule1/models/option/expiration"

      property :symbol, from: :rootsymbol
      property :last, coerce: Float
      property :bid, coerce: Float
      property :ask, coerce: Float
      property :strike_price, from: :strikeprice, coerce: Float
      property :days_to_expiration, coerce: Integer
      property :subclass, from: :op_subclass
      property :open_interest, from: :pr_openinterest
      property :volume, from: :vl, coerce: Integer
      property :expiration_date, from: :xdate

      def mark
        (bid + ask) / 2
      end

      def risk_capital
        strike_price - mark
      end

      def rorc
        mark / risk_capital
      end

      def multiplier
        365.0 / days_to_expiration
      end

      def arorc
        rorc * multiplier
      end

      def to_s
        string = "Strike: " + "%.2f" % strike_price + "\n"
        string << "Open Interest: #{open_interest}\n"
        string << "Volume: #{volume}\n"
        string << "ARORC: "
        string << "%.2f" % "#{arorc * 100}"
        string << "%"
      end
    end
  end
end
