# frozen_string_literal: true

RSpec.describe TeamMember, type: :model do
  context 'enums' do
    it { is_expected.to define_enum_for(:billable_type).with_values(outsourcing: 0, consulting: 1, training: 2, domestic_product: 3) }
  end

  context 'associations' do
    it { is_expected.to belong_to(:company) }
    it { is_expected.to have_many(:memberships).dependent(:destroy) }
    it { is_expected.to have_many(:teams).through(:memberships) }
    it { is_expected.to have_many(:demand_comments).dependent(:nullify) }
    it { is_expected.to have_many(:demand_blocks).inverse_of(:blocker).dependent(:destroy) }
    it { is_expected.to have_many(:demand_unblocks).class_name('DemandBlock').inverse_of(:unblocker).dependent(:destroy) }
    it { is_expected.to have_many(:item_assignments).dependent(:destroy) }
    it { is_expected.to have_many(:demands).through(:item_assignments) }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :name }

    context 'uniqueness' do
      let(:company) { Fabricate :company }
      let(:team) { Fabricate :team, company: company }

      let!(:first_team_member) { Fabricate :team_member, company: company, name: 'bla', jira_account_id: 'foo' }
      let(:second_team_member) { Fabricate.build :team_member, company: company, name: 'bla', jira_account_id: 'foo' }

      let(:third_team_member) { Fabricate.build :team_member, company: company, name: 'xpto', jira_account_id: 'foo' }
      let(:fourth_team_member) { Fabricate.build :team_member, company: company, name: 'bla', jira_account_id: 'sbbrubles' }
      let(:fifth_team_member) { Fabricate.build :team_member, name: 'bla', jira_account_id: 'foo' }

      it 'invalidates the model and add the errors' do
        expect(second_team_member.valid?).to be false
        expect(second_team_member.errors.full_messages).to eq ['Nome Apenas um nome para a empresa e o id de conta do Jira.']

        expect(third_team_member.valid?).to be true
        expect(fourth_team_member.valid?).to be true
        expect(fifth_team_member.valid?).to be true
      end
    end
  end

  context 'scopes' do
    describe '.active' do
      let(:active) { Fabricate :team_member, end_date: nil }
      let(:other_active) { Fabricate :team_member, end_date: nil }
      let(:inactive) { Fabricate :team_member, active: false }

      it { expect(described_class.active).to match_array [active, other_active] }
    end
  end

  describe '#to_hash' do
    let(:team_member) { Fabricate :team_member }

    it { expect(team_member.to_hash).to eq(member_name: team_member.name, jira_account_id: team_member.jira_account_id) }
  end

  describe '#active?' do
    let(:team_member) { Fabricate :team_member, end_date: 1.day.ago }
    let(:other_team_member) { Fabricate :team_member, end_date: nil }

    it { expect(team_member.active?).to be false }
    it { expect(other_team_member.active?).to be true }
  end
end
