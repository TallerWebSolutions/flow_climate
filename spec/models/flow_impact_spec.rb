# frozen_string_literal: true

RSpec.describe FlowImpact, type: :model do
  include Rails.application.routes.url_helpers

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

  context 'scopes' do
    describe '.opened' do
      context 'with data' do
        let(:flow_impact) { Fabricate :flow_impact, start_date: 2.days.ago, end_date: 1.day.ago }
        let(:other_flow_impact) { Fabricate :flow_impact, start_date: 2.days.ago, end_date: nil }

        it { expect(described_class.all.opened).to eq [other_flow_impact] }
      end

      context 'without data' do
        it { expect(described_class.all.opened).to eq [] }
      end
    end
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

  describe '#to_hash' do
    before { travel_to Time.zone.local(2019, 10, 17, 11, 20, 0) }

    after { travel_back }

    let(:project) { Fabricate :project }

    context 'without end date and demand' do
      let(:flow_impact) { Fabricate :flow_impact, project: project, demand: nil, start_date: 2.days.ago, end_date: nil }

      it { expect(flow_impact.to_hash).to eq(demand: nil, end_date: nil, impact_duration: 172_800.0, impact_type: I18n.t("activerecord.attributes.flow_impact.enums.impact_type.#{flow_impact.impact_type}"), project_name: project.name, start_date: '2019-10-15T11:20:00-03:00', impact_url: company_flow_impact_path(project.company, flow_impact)) }
    end

    context 'with end date and demand' do
      let(:demand) { Fabricate :demand }
      let(:flow_impact) { Fabricate :flow_impact, project: project, demand: demand, start_date: 2.days.ago, end_date: 1.day.ago }

      it { expect(flow_impact.to_hash).to eq(project_name: project.name, impact_type: I18n.t("activerecord.attributes.flow_impact.enums.impact_type.#{flow_impact.impact_type}"), demand: demand.external_id, start_date: '2019-10-15T11:20:00-03:00', end_date: '2019-10-16T11:20:00-03:00', impact_duration: 86_400.0, impact_url: company_flow_impact_path(project.company, flow_impact)) }
    end
  end
end
