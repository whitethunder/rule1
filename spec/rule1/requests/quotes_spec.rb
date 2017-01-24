require "spec_helper"

describe Rule1::Requests::Quotes do
  let(:params) {{
    symbols: ["ABC", "123"]
  }}

  subject { described_class.new(params) }

  its(:symbols) { is_expected.to eq params[:symbols] }
  its(:query_string) { is_expected.to eq "symbols=ABC,123" }
end
