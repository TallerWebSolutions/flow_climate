# frozen_string_literal: true

RSpec.describe FlowEvent, type: :model do
  include Rails.application.routes.url_helpers

  context 'enums' do
    it { is_expected.to define_enum_for(:event_type).with_values(other_team_dependency: 0, api_not_ready: 1, customer_not_available: 2, other_demand_dependency: 3, fixes_out_of_scope: 4, external_service_unavailable: 5, day_off: 6) }
    it { is_expected.to define_enum_for(:event_size).with_values(small: 0, medium: 1, large: 2) }
  end

  context 'associations' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:project) }
    it { is_expected.to belong_to(:risk_review) }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :event_type }
    it { is_expected.to validate_presence_of :event_size }
    it { is_expected.to validate_presence_of :event_date }
    it { is_expected.to validate_presence_of :event_description }
  end

  describe '#to_hash' do
    before { travel_to Time.zone.local(2019, 10, 17, 11, 20, 0) }

    let(:project) { Fabricate :project }

    context 'with a demand' do
      let(:demand) { Fabricate :demand }
      let(:flow_event) { Fabricate :flow_event, project: project, event_date: 2.days.ago }

      it { expect(flow_event.to_hash).to eq(project_name: project.name, event_type: I18n.t("activerecord.attributes.flow_event.enums.event_type.#{flow_event.event_type}"), event_size: I18n.t("activerecord.attributes.flow_event.enums.event_size.#{flow_event.event_size}"), event_date: '2019-10-15T11:20:00-03:00', event_end_date: flow_event.event_end_date, event_url: company_flow_event_path(project.company, flow_event)) }
    end
  end
end
