module Rule1
  module Models
    class Quote < Model
      property :symbol
      property :last, coerce: Float
      property :open, from: :opn, coerce: Float
      property :high, from: :hi, coerce: Float
      property :low, from: :lo, coerce: Float
      property :volume, from: :vl, coerce: Float
    end
  end
end
