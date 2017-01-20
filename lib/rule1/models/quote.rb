module Rule1
  module Models
    class Quote < Model
      property :symbol
      property :last, coerce: Float
    end
  end
end
