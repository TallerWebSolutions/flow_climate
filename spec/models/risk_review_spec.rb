# frozen_string_literal: true

RSpec.describe RiskReview, type: :model do
  context 'associations' do
    it { is_expected.to belong_to :company }
    it { is_expected.to belong_to :product }
    it { is_expected.to have_many(:demand_blocks).dependent(:nullify) }
    it { is_expected.to have_many(:demands).dependent(:nullify) }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :company }
    it { is_expected.to validate_presence_of :product }

    context 'uniqueness' do
      let(:company) { Fabricate :company }
      let(:customer) { Fabricate :customer, company: company }
      let(:product) { Fabricate :product, customer: customer }
      let!(:risk_review) { Fabricate :risk_review, meeting_date: Time.zone.today, product: product }
      let!(:same_risk_review) { Fabricate.build :risk_review, meeting_date: Time.zone.today, product: product }
      let!(:other_date_risk_review) { Fabricate.build :risk_review, meeting_date: 2.days.from_now, product: product }
      let!(:other_product_risk_review) { Fabricate.build :risk_review, meeting_date: Time.zone.today }

      before { same_risk_review.valid? }

      it { expect(risk_review.valid?).to be true }
      it { expect(same_risk_review.valid?).to be false }
      it { expect(same_risk_review.errors_on(:product)).to eq [I18n.t('risk_review.attributes.validations.product_uniqueness')] }
      it { expect(other_date_risk_review.valid?).to be true }
      it { expect(other_product_risk_review.valid?).to be true }
    end
  end

  context 'delegations' do
    it { is_expected.to delegate_method(:name).to(:product).with_prefix }
  end
end
