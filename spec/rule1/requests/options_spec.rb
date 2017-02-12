require "spec_helper"

describe Rule1::Requests::Options do
  let(:params) {{
    symbol: "RUT",
    fields: ["bid", "ask", "last"],
    strike_price_gte: "10",
    strike_price_lte: "15",
    option_type: "put",
    expiration_date: "20170101"
    # expiration_date: "2017-01-01"
  }}

  subject { described_class.new(params) }

  its(:symbol) { is_expected.to eq params[:symbol] }
  its(:fields) { is_expected.to eq params[:fields] }
  its(:strike_price_gte) { is_expected.to eq params[:strike_price_gte] }
  its(:strike_price_lte) { is_expected.to eq params[:strike_price_lte] }
  its(:option_type) { is_expected.to eq params[:option_type] }
  its(:expiration_date) { is_expected.to eq "20170101" }

  its(:query_string) { is_expected.to match /symbol=.+?fids=.+?query=/ }
end
