RSpec.describe Rule1::Resources::Quotes do
  let(:symbols) { ["AAPL", "GOOG"] }

  describe ".get", vcr: { cassette_name: "resources/quotes" } do
    subject(:quotes) { described_class.get(symbols) }

    its(:size) { is_expected.to eq 2 }
    its(:first) { is_expected.to be_a Rule1::Models::Quote }
  end
end
