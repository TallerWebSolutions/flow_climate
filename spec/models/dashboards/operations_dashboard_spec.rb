# frozen_string_literal: true

RSpec.describe Dashboards::OperationsDashboard, type: :model do
  context 'associations' do
    it { is_expected.to belong_to(:team_member) }
    it { is_expected.to belong_to(:first_delivery).class_name('Demand').optional }

    it { is_expected.to have_many(:operations_dashboard_pairings).class_name('Dashboards::OperationsDashboardPairing').dependent(:destroy) }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :dashboard_date }
    it { is_expected.to validate_presence_of :bugs_count }
    it { is_expected.to validate_presence_of :delivered_demands_count }
    it { is_expected.to validate_presence_of :lead_time_max }
    it { is_expected.to validate_presence_of :lead_time_min }
    it { is_expected.to validate_presence_of :lead_time_p80 }
    it { is_expected.to validate_presence_of :projects_count }
  end
end
