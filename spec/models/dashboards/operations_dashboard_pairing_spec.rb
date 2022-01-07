# frozen_string_literal: true

RSpec.describe Dashboards::OperationsDashboardPairing, type: :model do
  context 'associations' do
    it { is_expected.to belong_to :operations_dashboard }
    it { is_expected.to belong_to(:pair).class_name('TeamMember') }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :pair_times }
  end
end
