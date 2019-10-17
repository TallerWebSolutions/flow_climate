# frozen_string_literal: true

RSpec.describe FlowImpact, type: :model do
  context 'enums' do
    it { is_expected.to define_enum_for(:impact_type).with_values(other_team_dependency: 0, api_not_ready: 1, customer_not_available: 2, other_demand_dependency: 3, fixes_out_of_scope: 4, external_service_unavailable: 5) }
  end

  context 'associations' do
    it { is_expected.to belong_to(:project) }
    it { is_expected.to belong_to(:demand) }
    it { is_expected.to belong_to(:risk_review) }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :project }
    it { is_expected.to validate_presence_of :impact_type }
    it { is_expected.to validate_presence_of :start_date }
    it { is_expected.to validate_presence_of :impact_description }
  end

  describe '#impact_duration' do
    before { travel_to Time.zone.local(2019, 10, 17, 11, 20, 0) }

    after { travel_back }

    context 'without end date' do
      let(:flow_impact) { Fabricate :flow_impact, start_date: 2.days.ago, end_date: nil }

      it { expect(flow_impact.impact_duration).to eq 172_800.0 }
    end

    context 'with end date' do
      let(:flow_impact) { Fabricate :flow_impact, start_date: 2.days.ago, end_date: 1.day.ago }

      it { expect(flow_impact.impact_duration).to eq 86_400.0 }
    end
  end
end
