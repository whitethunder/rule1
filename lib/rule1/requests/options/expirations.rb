module Rule1
  module Requests
    class Options::Expirations < Request
      property :symbol, required: true

      def query_string
        "symbol=#{symbol}"
      end
    end
  end
end
