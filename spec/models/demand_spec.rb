# frozen_string_literal: true

RSpec.describe Demand, type: :model do
  context 'associations' do
    it { is_expected.to belong_to :project_result }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :demand_id }
    it { is_expected.to validate_presence_of :effort }
  end
end
