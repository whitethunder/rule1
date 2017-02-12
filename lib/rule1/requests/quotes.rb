module Rule1
  module Requests
    class Quotes < Request
      property :symbols, required: true

      def query_string
        "symbols=#{Array(symbols).join(',')}"
      end
    end
  end
end
