class Rule1::Quote < Model
  property :symbol
  property :last, coerce: Float
end
