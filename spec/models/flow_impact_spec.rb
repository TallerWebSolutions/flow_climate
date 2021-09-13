# frozen_string_literal: true

RSpec.describe FlowImpact, type: :model do
  include Rails.application.routes.url_helpers

  context 'enums' do
    it { is_expected.to define_enum_for(:impact_type).with_values(other_team_dependency: 0, api_not_ready: 1, customer_not_available: 2, other_demand_dependency: 3, fixes_out_of_scope: 4, external_service_unavailable: 5) }
    it { is_expected.to define_enum_for(:impact_size).with_values(small: 0, medium: 1, large: 2) }
  end

  context 'associations' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:project) }
    it { is_expected.to belong_to(:demand) }
    it { is_expected.to belong_to(:risk_review) }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :project }
    it { is_expected.to validate_presence_of :impact_type }
    it { is_expected.to validate_presence_of :impact_size }
    it { is_expected.to validate_presence_of :impact_date }
    it { is_expected.to validate_presence_of :impact_description }
  end

  describe '#to_hash' do
    before { travel_to Time.zone.local(2019, 10, 17, 11, 20, 0) }

    let(:project) { Fabricate :project }

    context 'with a demand' do
      let(:demand) { Fabricate :demand }
      let(:flow_impact) { Fabricate :flow_impact, project: project, demand: demand, impact_date: 2.days.ago }

      it { expect(flow_impact.to_hash).to eq(project_name: project.name, impact_type: I18n.t("activerecord.attributes.flow_impact.enums.impact_type.#{flow_impact.impact_type}"), impact_size: I18n.t("activerecord.attributes.flow_impact.enums.impact_size.#{flow_impact.impact_size}"), demand: demand.external_id, impact_date: '2019-10-15T11:20:00-03:00', impact_url: company_flow_impact_path(project.company, flow_impact)) }
    end
  end
end
