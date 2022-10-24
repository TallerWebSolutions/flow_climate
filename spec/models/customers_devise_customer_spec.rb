# frozen_string_literal: true

RSpec.describe CustomersDeviseCustomer do
  context 'associations' do
    it { is_expected.to belong_to :customer }
    it { is_expected.to belong_to :devise_customer }
  end
end
