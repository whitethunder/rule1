require "spec_helper"

describe Rule1::Models::Option do
  let(:params) { {
    rootsymbol: "XYZ",
    last: "12.34",
    strikeprice: "12.00",
    days_to_expiration: "30",
    op_subclass: "1",
    pr_openinterest: "123",
    vl: "234"
  } }

  subject(:option) { described_class.new(params) }

  its(:symbol) { is_expected.to eq params[:rootsymbol] }
  its(:mark) { is_expected.to eq params[:last].to_f }
  its(:strike_price) { is_expected.to eq params[:strikeprice].to_f }
  its(:days_to_expiration) { is_expected.to eq params[:days_to_expiration].to_i }
  its(:subclass) { is_expected.to eq params[:op_subclass] }
  its(:open_interest) { is_expected.to eq params[:pr_openinterest] }
  its(:volume) { is_expected.to eq params[:vl].to_i }
end
