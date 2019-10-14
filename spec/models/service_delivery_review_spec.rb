# frozen_string_literal: true

RSpec.describe ServiceDeliveryReview, type: :model do
  context 'associations' do
    it { is_expected.to belong_to :company }
    it { is_expected.to belong_to :product }
    it { is_expected.to have_many(:demands).dependent(:nullify) }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :company }
    it { is_expected.to validate_presence_of :product }

    context 'uniqueness' do
      let(:company) { Fabricate :company }
      let(:customer) { Fabricate :customer, company: company }
      let(:product) { Fabricate :product, customer: customer }
      let!(:service_delivery_review) { Fabricate :service_delivery_review, meeting_date: Time.zone.today, product: product }
      let!(:same_service_delivery_review) { Fabricate.build :service_delivery_review, meeting_date: Time.zone.today, product: product }
      let!(:other_date_service_delivery_review) { Fabricate.build :service_delivery_review, meeting_date: 2.days.from_now, product: product }
      let!(:other_product_service_delivery_review) { Fabricate.build :service_delivery_review, meeting_date: Time.zone.today }

      before { same_service_delivery_review.valid? }

      it { expect(service_delivery_review.valid?).to be true }
      it { expect(same_service_delivery_review.valid?).to be false }
      it { expect(same_service_delivery_review.errors_on(:product)).to eq [I18n.t('service_delivery_review.attributes.validations.product_uniqueness')] }
      it { expect(other_date_service_delivery_review.valid?).to be true }
      it { expect(other_product_service_delivery_review.valid?).to be true }
    end
  end

  context 'delegations' do
    it { is_expected.to delegate_method(:name).to(:product).with_prefix }
    it { is_expected.to delegate_method(:count).to(:bugs).with_prefix }
    it { is_expected.to delegate_method(:count).to(:expedites).with_prefix }
  end

  shared_context 'service delivery data' do
    let(:company) { Fabricate :company }
    let(:customer) { Fabricate :customer, company: company }
    let(:product) { Fabricate :product, customer: customer }
    let(:project) { Fabricate :project, products: [product] }

    let!(:service_delivery_review) { Fabricate :service_delivery_review, product: product, expedite_max_pull_time_sla: 2.hours.to_i, lead_time_bottom_threshold: 23.hours, lead_time_top_threshold: 120.hours }
    let!(:other_service_delivery_review) { Fabricate :service_delivery_review }

    let(:stage) { Fabricate :stage, company: company, commitment_point: false, end_point: true, order: 1, projects: [project], stage_stream: :downstream }
    let(:other_stage) { Fabricate :stage, company: company, commitment_point: true, end_point: false, order: 0, projects: [project], stage_stream: :downstream }

    let(:portfolio_unit) { Fabricate :portfolio_unit, product: product }
    let(:other_portfolio_unit) { Fabricate :portfolio_unit, product: product }

    let!(:first_demand) { Fabricate :demand, project: project, portfolio_unit: portfolio_unit, service_delivery_review: service_delivery_review, demand_type: :bug, class_of_service: :expedite }
    let!(:second_demand) { Fabricate :demand, project: project, portfolio_unit: other_portfolio_unit, service_delivery_review: service_delivery_review, demand_type: :bug, class_of_service: :standard }
    let!(:third_demand) { Fabricate :demand, project: project, portfolio_unit: portfolio_unit, service_delivery_review: service_delivery_review, demand_type: :feature, class_of_service: :expedite }
    let!(:fourth_demand) { Fabricate :demand, project: project, portfolio_unit: nil, service_delivery_review: service_delivery_review, demand_type: :chore, class_of_service: :expedite }

    let!(:first_transition) { Fabricate :demand_transition, stage: stage, demand: first_demand, last_time_in: 10.days.ago, last_time_out: 1.minute.ago }
    let!(:second_transition) { Fabricate :demand_transition, stage: stage, demand: second_demand, last_time_in: 6.days.ago, last_time_out: 1.hour.ago }
    let!(:third_transition) { Fabricate :demand_transition, stage: stage, demand: third_demand, last_time_in: 96.hours.ago, last_time_out: 95.hours.ago }
    let!(:fourth_transition) { Fabricate :demand_transition, stage: stage, demand: fourth_demand, last_time_in: 6.days.ago, last_time_out: 1.day.ago }

    let!(:fifth_transition) { Fabricate :demand_transition, stage: other_stage, demand: first_demand, last_time_in: 18.days.ago, last_time_out: 10.days.ago }
    let!(:sixth_transition) { Fabricate :demand_transition, stage: other_stage, demand: second_demand, last_time_in: 7.days.ago, last_time_out: 6.days.ago }
    let!(:seventh_transition) { Fabricate :demand_transition, stage: other_stage, demand: third_demand, last_time_in: 97.hours.ago, last_time_out: 96.hours.ago }
    let!(:eigth_transition) { Fabricate :demand_transition, stage: other_stage, demand: fourth_demand, last_time_in: 11.days.ago, last_time_out: 6.days.ago }
  end

  describe '#bugs_count' do
    include_context 'service delivery data'

    it 'returns the bugs count' do
      expect(service_delivery_review.bugs_count).to eq 2
      expect(other_service_delivery_review.bugs_count).to eq 0
    end
  end

  describe '#bug_percentage' do
    include_context 'service delivery data'

    it 'returns the bugs count percentage' do
      expect(service_delivery_review.bug_percentage).to eq 50.0
      expect(other_service_delivery_review.bug_percentage).to eq 0
    end
  end

  describe '#demands_lead_time_p80' do
    before { travel_to Time.zone.local(2019, 10, 14, 17, 20, 0) }

    after { travel_back }

    include_context 'service delivery data'

    it 'returns the lead time percentile 80 value' do
      expect(service_delivery_review.demands_lead_time_p80).to be_within(0.3).of 535_679.8
      expect(other_service_delivery_review.demands_lead_time_p80).to eq 0
    end
  end

  describe '#bugs' do
    include_context 'service delivery data'

    it 'returns the bugs' do
      expect(service_delivery_review.bugs).to match_array [first_demand, second_demand]
      expect(other_service_delivery_review.bugs).to eq []
    end
  end

  describe '#expedites' do
    include_context 'service delivery data'

    it 'returns the expedites' do
      expect(service_delivery_review.expedites).to match_array [first_demand, third_demand, fourth_demand]
      expect(other_service_delivery_review.expedites).to eq []
    end
  end

  describe '#expedites_delayed' do
    include_context 'service delivery data'

    it 'returns the expedites delayed' do
      expect(service_delivery_review.expedites_delayed).to match_array [first_demand, fourth_demand]
      expect(other_service_delivery_review.expedites_delayed).to eq []
    end
  end

  describe '#expedites_not_delayed' do
    include_context 'service delivery data'

    it 'returns the expedites with no delay' do
      expect(service_delivery_review.expedites_not_delayed).to match_array [third_demand]
      expect(other_service_delivery_review.expedites_not_delayed).to eq []
    end
  end

  describe '#expedites_delayed_share' do
    include_context 'service delivery data'

    it 'returns the delayed expedites share' do
      expect(service_delivery_review.expedites_delayed_share).to eq 0.6666666666666666
      expect(other_service_delivery_review.expedites_delayed_share).to eq 0
    end
  end

  describe '#no_bugs' do
    include_context 'service delivery data'

    it 'returns the bug demands' do
      expect(service_delivery_review.no_bugs).to match_array [third_demand, fourth_demand]
      expect(other_service_delivery_review.no_bugs).to eq []
    end
  end

  describe '#lead_time_breakdown' do
    include_context 'service delivery data'

    it 'returns the lead time breakdown to the entire demand array' do
      expect(service_delivery_review.lead_time_breakdown.keys).to eq [other_stage.name]
      expect(service_delivery_review.lead_time_breakdown[other_stage.name]).to match_array [fifth_transition, sixth_transition, seventh_transition, eigth_transition]

      expect(other_service_delivery_review.lead_time_breakdown).to eq({})
    end
  end

  describe '#portfolio_module_breakdown' do
    include_context 'service delivery data'

    it 'returns the portfolio module breakdown to the entire demands array' do
      portfolio_module_breakdown = service_delivery_review.portfolio_module_breakdown
      expect(portfolio_module_breakdown.keys).to eq [other_portfolio_unit, portfolio_unit]
      expect(portfolio_module_breakdown[portfolio_unit]).to match_array [first_demand, third_demand]
      expect(portfolio_module_breakdown[other_portfolio_unit]).to match_array [second_demand]

      expect(other_service_delivery_review.portfolio_module_breakdown).to eq({})
    end
  end

  describe '#overserved_demands' do
    include_context 'service delivery data'

    it 'returns the overserved demands in array' do
      overserved_demands = service_delivery_review.overserved_demands
      expect(overserved_demands[:value]).to eq [third_demand]
      expect(overserved_demands[:share]).to eq 0.25

      expect(other_service_delivery_review.overserved_demands[:value]).to eq([])
    end
  end

  describe '#underserved_demands' do
    include_context 'service delivery data'

    it 'returns the underserved demands in array' do
      underserved_demands = service_delivery_review.underserved_demands
      expect(underserved_demands[:value]).to match_array [first_demand]
      expect(underserved_demands[:share]).to eq 0.25

      expect(other_service_delivery_review.underserved_demands[:value]).to eq([])
    end
  end

  describe '#fit_for_purpose_demands' do
    include_context 'service delivery data'

    it 'returns the fit for purpose demands in array' do
      fit_for_purpose_demands = service_delivery_review.fit_for_purpose_demands
      expect(fit_for_purpose_demands[:value]).to match_array [second_demand, fourth_demand]
      expect(fit_for_purpose_demands[:share]).to eq 0.5

      expect(other_service_delivery_review.fit_for_purpose_demands[:value]).to eq([])
    end
  end

  describe '#longest_stage' do
    include_context 'service delivery data'

    it 'returns the longest stage in demands array' do
      longest_stage = service_delivery_review.longest_stage
      expect(longest_stage[:name]).to eq other_stage.name
      expect(longest_stage[:time_in_stage]).to be_within(0.1).of(1_213_200.0)

      expect(other_service_delivery_review.longest_stage).to eq({})
    end
  end
end
