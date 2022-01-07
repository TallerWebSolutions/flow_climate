# frozen_string_literal: true

RSpec.describe ProjectBrokenWipLog, type: :model do
  context 'associations' do
    it { is_expected.to belong_to :project }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :project_wip }
    it { is_expected.to validate_presence_of :demands_ids }
  end
end
