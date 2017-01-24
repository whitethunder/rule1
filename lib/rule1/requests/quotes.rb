module Rule1
  module Requests
    class Quotes < Request
      property :symbols, required: true

      def query_string
        "symbols=#{symbols.join(',')}"
      end
    end
  end
end
