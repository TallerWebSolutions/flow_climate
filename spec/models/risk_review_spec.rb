# frozen_string_literal: true

RSpec.describe RiskReview, type: :model do
  context 'associations' do
    it { is_expected.to belong_to :company }
    it { is_expected.to belong_to :product }
    it { is_expected.to have_many(:demand_blocks).dependent(:nullify) }
    it { is_expected.to have_many(:flow_events).dependent(:nullify) }
    it { is_expected.to have_many(:demands).dependent(:nullify) }
    it { is_expected.to have_many(:risk_review_action_items).dependent(:destroy) }
  end

  context 'validations' do
    context 'uniqueness' do
      let(:company) { Fabricate :company }
      let(:customer) { Fabricate :customer, company: company }
      let(:product) { Fabricate :product, company: company, customer: customer }
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
    let(:company) { Fabricate :company }
    let(:product) { Fabricate :product, company: company }
    let(:risk_review) { Fabricate :risk_review, lead_time_outlier_limit: 5, weekly_avg_blocked_time: [2, 3], monthly_avg_blocked_time: [2] }
    let(:other_risk_review) { Fabricate :risk_review, lead_time_outlier_limit: 2 }

    let(:feature_type) { Fabricate :work_item_type, company: company, name: 'Feature' }
    let(:bug_type) { Fabricate :work_item_type, company: company, name: 'Bug', quality_indicator_type: true }
    let(:chore_type) { Fabricate :work_item_type, company: company, name: 'Chore' }

    let!(:first_demand) { Fabricate :demand, risk_review: risk_review, work_item_type: bug_type, commitment_date: 10.days.ago, end_date: Time.zone.now }
    let!(:second_demand) { Fabricate :demand, risk_review: risk_review, work_item_type: bug_type, commitment_date: 6.days.ago, end_date: Time.zone.now }
    let!(:third_demand) { Fabricate :demand, risk_review: risk_review, work_item_type: feature_type, commitment_date: 4.days.ago, end_date: Time.zone.now }
    let!(:fourth_demand) { Fabricate :demand, risk_review: risk_review, work_item_type: chore_type, commitment_date: 6.days.ago, end_date: nil }

    let!(:first_demand_block) { Fabricate :demand_block, demand: first_demand, risk_review: risk_review, block_time: Time.zone.parse('2018-03-05 23:00'), unblock_time: nil }
    let!(:second_demand_block) { Fabricate :demand_block, demand: first_demand, risk_review: risk_review, block_time: Time.zone.parse('2018-03-06 10:00'), unblock_time: nil }
    let!(:third_demand_block) { Fabricate :demand_block, demand: second_demand, risk_review: risk_review, block_time: Time.zone.parse('2018-03-06 14:00'), unblock_time: Time.zone.parse('2018-03-06 15:00') }

    let!(:first_flow_event) { Fabricate :flow_event, risk_review: risk_review, event_date: Time.zone.parse('2018-03-05 23:00') }
    let!(:second_flow_event) { Fabricate :flow_event, risk_review: risk_review, event_date: Time.zone.parse('2018-03-06 10:00') }
    let!(:third_flow_event) { Fabricate :flow_event, risk_review: risk_review, event_date: Time.zone.parse('2018-03-06 14:00') }
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

    it 'returns the percentage of demands with lead time above the outlier limit' do
      expect(risk_review.outlier_demands_percentage).to eq 50.0
      expect(other_risk_review.outlier_demands_percentage).to eq 0
    end
  end

  describe '#blocks_per_demand' do
    include_context 'risk reviews data'

    it 'returns the blocks per demand' do
      expect(risk_review.blocks_per_demand).to eq 0.75
      expect(other_risk_review.blocks_per_demand).to eq 0
    end
  end

  describe '#events_per_demand' do
    include_context 'risk reviews data'

    it 'returns the events per demand' do
      expect(risk_review.events_per_demand).to eq 0.75
      expect(other_risk_review.events_per_demand).to eq 0
    end
  end

  describe '#bugs_count' do
    include_context 'risk reviews data'

    it 'returns the count of bugs' do
      expect(risk_review.bugs_count).to eq 2
      expect(other_risk_review.bugs_count).to eq 0
    end
  end

  describe '#bug_percentage' do
    include_context 'risk reviews data'

    it 'returns the percentage of bugs' do
      expect(risk_review.bug_percentage).to eq 50.0
      expect(other_risk_review.bug_percentage).to eq 0
    end
  end

  describe '#demands_lead_time_p80' do
    before { travel_to Time.zone.local(2019, 10, 17, 10, 0, 0) }

    include_context 'risk reviews data'

    it 'returns the p80 lead time' do
      expect(risk_review.demands_lead_time_p80).to be_within(0.01).of 725_760.00
      expect(other_risk_review.demands_lead_time_p80).to eq 0
    end
  end

  describe '#bugs' do
    include_context 'risk reviews data'

    it 'returns the bugs' do
      expect(risk_review.bugs).to match_array [first_demand, second_demand]
      expect(other_risk_review.bugs).to eq []
    end
  end

  describe '#avg_blocked_time_in_weeks' do
    it 'returns the average block time data' do
      travel_to Time.zone.local(2018, 3, 6, 10, 0, 0) do
        company = Fabricate :company

        feature_type = Fabricate :work_item_type, company: company, name: 'Feature'
        bug_type = Fabricate :work_item_type, company: company, name: 'Bug', quality_indicator_type: true
        chore_type = Fabricate :work_item_type, company: company, name: 'Chore'

        product = Fabricate :product, company: company
        risk_review = Fabricate :risk_review, product: product, meeting_date: Time.zone.yesterday, lead_time_outlier_limit: 5, weekly_avg_blocked_time: [2, 3], monthly_avg_blocked_time: [2]
        other_risk_review = Fabricate :risk_review, product: product, meeting_date: Time.zone.today, lead_time_outlier_limit: 2

        first_demand = Fabricate :demand, company: company, risk_review: risk_review, work_item_type: bug_type, commitment_date: 10.days.ago, end_date: Time.zone.now
        second_demand = Fabricate :demand, company: company, risk_review: risk_review, work_item_type: bug_type, commitment_date: 6.days.ago, end_date: Time.zone.now
        Fabricate :demand, company: company, risk_review: risk_review, work_item_type: feature_type, commitment_date: 4.days.ago, end_date: Time.zone.now
        Fabricate :demand, company: company, risk_review: risk_review, work_item_type: chore_type, commitment_date: 6.days.ago, end_date: nil

        Fabricate :demand_block, demand: first_demand, risk_review: risk_review, block_time: Time.zone.parse('2018-03-05 23:00'), unblock_time: nil
        Fabricate :demand_block, demand: first_demand, risk_review: risk_review, block_time: Time.zone.parse('2018-03-06 10:00'), unblock_time: nil
        Fabricate :demand_block, demand: second_demand, risk_review: risk_review, block_time: Time.zone.parse('2018-03-06 14:00'), unblock_time: Time.zone.parse('2018-03-06 15:00')

        expect(risk_review.avg_blocked_time_in_weeks).to eq({ chart: { data: [0.0005555555555555556, 0.0008333333333333334], name: I18n.t('risk_reviews.show.average_blocked_time') }, x_axis: [Time.zone.today.end_of_week] })
        expect(other_risk_review.avg_blocked_time_in_weeks).to eq({ chart: { data: nil, name: I18n.t('risk_reviews.show.average_blocked_time') }, x_axis: [] })
      end
    end
  end
end
