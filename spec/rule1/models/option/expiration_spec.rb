require "spec_helper"

RSpec.describe Rule1::Models::Option::Expiration do
  let(:params) {{
    symbol: "RUT",
    date: "2017-04-21"
  }}

  subject { described_class.new(params) }

  its(:symbol) { is_expected.to eq params[:symbol] }
  its(:date) { is_expected.to be_a Date }
  its(:api_formatted) { is_expected.to eq "20170421" }

  describe "#days_until" do
    before { allow(Date).to receive(:today).and_return(Date.parse("2017-03-15")) }

    its(:days_until) { is_expected.to eq 37 }
  end
end
