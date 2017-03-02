module Rule1
  module Resources
    class Quotes < Resource
      def self.get(symbols)
        response = Requests::Quotes.new(symbols: symbols).get(path)

        result = response.dig('response', 'quotes', 'quote')
        result = [result] if result.is_a?(Hash)

        result.map! { |r| Models::Quote.new(r) }
      end

      def self.path
        "/v1/market/ext/quotes"
      end
    end
  end
end
