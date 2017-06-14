module Rule1
  module Requests
    class Options < Request
      autoload :Expirations, "/home/mwhite/code/rule1/lib/rule1/requests/options/expirations"

      DEFAULT_FIELDS = "bid,ask,last,days_to_expiration,op_subclass,rootsymbol,strikeprice,pr_openinterest,vl,xdate"

      property :symbol, required: true
      property :fields, default: DEFAULT_FIELDS
      property :strike_price_gte
      property :strike_price_lte
      property :option_type
      # Commenting out with due to Hashie bug. Fixed after 3.4.6 (uneleased as of 1/25/17)
      property :expiration_date #, with: ->(v) { Date.parse(v).strftime("%Y%m%d") }

      def query_string
        params  = ["symbol=#{symbol}"]
        params << "fids=#{fields}"
        params << "#{conditions}" unless conditions.nil? || conditions.empty?

        params.join("&")
      end

      private

      def conditions
        params  = []
        params << "strikeprice-gte:#{strike_price_gte}" if strike_price_gte
        params << "strikeprice-lte:#{strike_price_lte}" if strike_price_lte
        params << "put_call-eq:#{option_type}" if option_type
        params << "xdate-eq:#{expiration_date}" if expiration_date

        params.empty? ? nil : "query=#{params.join(' AND ')}"
      end
    end
  end
end
