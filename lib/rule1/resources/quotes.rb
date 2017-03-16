module Rule1
  module Resources
    class Quotes < Resource
      def self.get(symbols)
        response = Requests::Quotes.new(symbols: symbols).get("/v1/market/ext/quotes")

        result = response.dig('response', 'quotes', 'quote')
        result = [result] if result.is_a?(Hash)

        result.map! { |r| Models::Quote.new(r) }
      end
    end
  end
end
