RSpec.describe Rule1::Resources::Options do
  describe ".get", vcr: { cassette_name: "resources/options" } do
    let(:symbol) { "GOOGL" }
    let(:option_type) { "put" }
    let(:params) { {
      symbol: symbol,
      fields: "bid,ask,last,strikeprice",
      strike_price_gte: 800,
      option_type: option_type
    } }

    subject(:quotes) { described_class.get(params) }

    it { is_expected.to be_an Array }
    its(:first) { is_expected.to be_a Rule1::Models::Put }

    it "populates the options correctly" do
      expect(quotes.first.ask).to eq 143.9
    end

    context "when the option type is a call" do
      let(:option_type) { "call" }

      its(:first) { is_expected.to be_a Rule1::Models::Call }
    end
  end
end
