module Rule1
  module Resources
    class Options < Resource
      def self.get(params)
        response = Requests::Options.new(params).get(path)

        result = response.dig('response', 'quotes', 'quote')

        if params[:option_type].downcase == "put"
          result.map! { |r| Models::Put.new(r) }
        else
          result.map! { |r| Models::Call.new(r) }
        end
      end

      def self.path
        "/v1/market/options/search"
      end
    end
  end
end
