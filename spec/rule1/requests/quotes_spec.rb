require "spec_helper"

describe Rule1::Requests::Quotes do
  subject { described_class.new(params) }

  context "when a single symbol is passed" do
    let(:params) {{
      symbols: "ABC"
    }}

    its(:symbols) { is_expected.to eq params[:symbols] }
    its(:query_string) { is_expected.to eq "symbols=ABC" }
  end

  context "when multiple symbols are passed" do
    let(:params) {{
      symbols: ["ABC", "123"]
    }}

    its(:symbols) { is_expected.to eq params[:symbols] }
    its(:query_string) { is_expected.to eq "symbols=ABC,123" }
  end
end
