module Rule1
  module Models
    class Option::Expiration < Model
      property :symbol
      property :date

      def date
        Date.parse(self[:date])
      end

      def api_formatted
        self[:date].gsub("-", "")
      end

      def days_until
        (date - Date.today).to_i
      end
    end
  end
end
