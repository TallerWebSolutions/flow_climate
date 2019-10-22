# frozen_string_literal: true

RSpec.describe RiskReview, type: :model do
  context 'associations' do
    it { is_expected.to belong_to :company }
    it { is_expected.to belong_to :product }
    it { is_expected.to have_many(:demand_blocks).dependent(:nullify) }
    it { is_expected.to have_many(:flow_impacts).dependent(:nullify) }
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

  shared_context 'risk reviews data' do
    let(:product) { Fabricate :product }
    let(:risk_review) { Fabricate :risk_review, lead_time_outlier_limit: 5 }
    let(:other_risk_review) { Fabricate :risk_review, lead_time_outlier_limit: 2 }

    let!(:first_demand) { Fabricate :demand, risk_review: risk_review, demand_type: :bug, commitment_date: 10.days.ago, end_date: Time.zone.now }
    let!(:second_demand) { Fabricate :demand, risk_review: risk_review, demand_type: :bug, commitment_date: 6.days.ago, end_date: Time.zone.now }
    let!(:third_demand) { Fabricate :demand, risk_review: risk_review, demand_type: :feature, commitment_date: 4.days.ago, end_date: Time.zone.now }
    let!(:fourth_demand) { Fabricate :demand, risk_review: risk_review, demand_type: :chore, commitment_date: 6.days.ago, end_date: nil }

    let!(:first_demand_block) { Fabricate :demand_block, demand: first_demand, risk_review: risk_review, block_time: Time.zone.parse('2018-03-05 23:00'), unblock_time: nil }
    let!(:second_demand_block) { Fabricate :demand_block, demand: first_demand, risk_review: risk_review, block_time: Time.zone.parse('2018-03-06 10:00'), unblock_time: nil }
    let!(:third_demand_block) { Fabricate :demand_block, demand: second_demand, risk_review: risk_review, block_time: Time.zone.parse('2018-03-06 14:00'), unblock_time: Time.zone.parse('2018-03-06 15:00') }

    let!(:first_flow_impact) { Fabricate :flow_impact, demand: first_demand, risk_review: risk_review, start_date: Time.zone.parse('2018-03-05 23:00') }
    let!(:second_flow_impact) { Fabricate :flow_impact, demand: first_demand, risk_review: risk_review, start_date: Time.zone.parse('2018-03-06 10:00') }
    let!(:third_flow_impact) { Fabricate :flow_impact, demand: second_demand, risk_review: risk_review, start_date: Time.zone.parse('2018-03-06 14:00') }
  end

  describe '#outlier_demands' do
    include_context 'risk reviews data'

    it 'returns the demands with lead time above the outlier limit' do
      expect(risk_review.outlier_demands).to match_array [first_demand, second_demand]
      expect(other_risk_review.outlier_demands).to match_array []
    end
  end

  describe '#outlier_demands_percentage' do
    include_context 'risk reviews data'

    it 'returns the demands with lead time above the outlier limit' do
      expect(risk_review.outlier_demands_percentage).to eq 50.0
      expect(other_risk_review.outlier_demands_percentage).to eq 0
    end
  end

  describe '#blocks_per_demand' do
    include_context 'risk reviews data'

    it 'returns the demands with lead time above the outlier limit' do
      expect(risk_review.blocks_per_demand).to eq 0.75
      expect(other_risk_review.blocks_per_demand).to eq 0
    end
  end

  describe '#impacts_per_demand' do
    include_context 'risk reviews data'

    it 'returns the demands with lead time above the outlier limit' do
      expect(risk_review.impacts_per_demand).to eq 0.75
      expect(other_risk_review.impacts_per_demand).to eq 0
    end
  end

  describe '#bugs_count' do
    include_context 'risk reviews data'

    it 'returns the demands with lead time above the outlier limit' do
      expect(risk_review.bugs_count).to eq 2
      expect(other_risk_review.bugs_count).to eq 0
    end
  end

  describe '#bug_percentage' do
    include_context 'risk reviews data'

    it 'returns the demands with lead time above the outlier limit' do
      expect(risk_review.bug_percentage).to eq 50.0
      expect(other_risk_review.bug_percentage).to eq 0
    end
  end

  describe '#demands_lead_time_p80' do
    before { travel_to Time.zone.local(2019, 10, 17, 10, 0, 0) }

    after { travel_back }

    include_context 'risk reviews data'

    it 'returns the demands with lead time above the outlier limit' do
      expect(risk_review.demands_lead_time_p80).to be_within(0.01).of 725_760.00
      expect(other_risk_review.demands_lead_time_p80).to eq 0
    end
  end

  describe '#bugs' do
    include_context 'risk reviews data'

    it 'returns the demands with lead time above the outlier limit' do
      expect(risk_review.bugs).to match_array [first_demand, second_demand]
      expect(other_risk_review.bugs).to eq []
    end
  end
end
