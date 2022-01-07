# frozen_string_literal: true

RSpec.describe StagesTeam, type: :model do
  context 'associations' do
    it { is_expected.to belong_to :stage }
    it { is_expected.to belong_to :team }
  end
end
