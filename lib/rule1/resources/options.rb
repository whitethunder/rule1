module Rule1
  module Resources
    class Options < Resource
      def self.get(params)
        response = Requests::Options.new(params).get("/v1/market/options/search")
        result = response.dig('response', 'quotes', 'quote')
        result = [result] if !result.nil? && !result.is_a?(Array)

        if params[:option_type].downcase == "put"
          result.map { |r| Models::Put.new(r) }
        else
          result.map { |r| Models::Call.new(r) }
        end
      end

      def self.expirations(symbol)
        response = Requests::Options::Expirations.new(symbol: symbol).get("/v1/market/options/expirations")
        result = response.dig('response', 'expirationdates', 'date')
        result.map { |date| Models::Option::Expiration.new(date: date, symbol: symbol) }
      end
    end
  end
end
