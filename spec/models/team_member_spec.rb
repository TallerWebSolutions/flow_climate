# frozen_string_literal: true

RSpec.describe TeamMember, type: :model do
  context 'enums' do
    it { is_expected.to define_enum_for(:billable_type).with_values(outsourcing: 0, consulting: 1, training: 2, domestic_product: 3) }
  end

  context 'associations' do
    it { is_expected.to belong_to :team }
    it { is_expected.to have_many(:demand_comments).dependent(:nullify) }
    it { is_expected.to have_and_belong_to_many(:demands).dependent(:destroy) }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :team }
    it { is_expected.to validate_presence_of :name }
    it { is_expected.to validate_presence_of :monthly_payment }
  end

  context 'scopes' do
    describe '.active' do
      let(:active) { Fabricate :team_member, active: true }
      let(:other_active) { Fabricate :team_member, active: true }
      let(:inactive) { Fabricate :team_member, active: false }

      it { expect(described_class.active).to match_array [active, other_active] }
    end
  end
end
