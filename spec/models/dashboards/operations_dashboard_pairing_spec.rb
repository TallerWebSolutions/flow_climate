# frozen_string_literal: true

RSpec.describe Dashboards::OperationsDashboardPairing do
  context 'associations' do
    it { is_expected.to belong_to :operations_dashboard }
    it { is_expected.to belong_to(:pair).class_name('TeamMember').optional(true) }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :pair_times }
  end
end
