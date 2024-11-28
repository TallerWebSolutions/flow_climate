# frozen_string_literal: true

RSpec.describe ProductUser do
  context 'with associations' do
    it { is_expected.to belong_to :product }
    it { is_expected.to belong_to :user }
  end

  context 'with validations' do
    let(:product_user) { Fabricate :product_user }

    context 'for uniqueness' do
      it { expect(product_user).to validate_uniqueness_of(:product_id).scoped_to(:user_id) }
    end
  end
end
