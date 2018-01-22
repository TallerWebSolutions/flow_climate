# frozen_string_literal: true

RSpec.describe Team, type: :model do
  context 'associations' do
    it { is_expected.to belong_to :company }
    it { is_expected.to have_many :team_members }
    it { is_expected.to have_many(:project_results).dependent(:restrict_with_error) }
    it { is_expected.to have_many(:projects).through(:project_results) }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :company }
    it { is_expected.to validate_presence_of :name }
  end

  context '#outsourcing_cost' do
    let(:company) { Fabricate :company }
    let(:team) { Fabricate :team, company: company }
    let!(:members) { Fabricate.times(4, :team_member, team: team, billable_type: :outsourcing) }
    let!(:consulting_members) { Fabricate.times(2, :team_member, team: team, billable_type: :consulting) }
    let!(:not_billable_members) { Fabricate.times(10, :team_member, team: team, billable: false, billable_type: nil) }
    let!(:not_active_members) { Fabricate.times(3, :team_member, team: team, billable: true, billable_type: :outsourcing, active: false) }

    it { expect(team.outsourcing_cost).to eq(members.sum(&:monthly_payment)) }
  end

  context '#management_cost' do
    let(:company) { Fabricate :company }
    let(:team) { Fabricate :team, company: company }
    let!(:members) { Fabricate.times(4, :team_member, team: team, billable_type: :outsourcing) }
    let!(:consulting_members) { Fabricate.times(2, :team_member, team: team, billable_type: :consulting) }
    let!(:not_billable_members) { Fabricate.times(10, :team_member, team: team, billable: false, billable_type: nil) }
    let!(:not_active_members) { Fabricate.times(3, :team_member, team: team, billable: false, active: false) }

    it { expect(team.management_cost).to eq(not_billable_members.sum(&:monthly_payment)) }
  end

  context '#consulting_cost' do
    let(:company) { Fabricate :company }
    let(:team) { Fabricate :team, company: company }
    let!(:members) { Fabricate.times(4, :team_member, team: team, billable_type: :outsourcing) }
    let!(:consulting_members) { Fabricate.times(2, :team_member, team: team, billable_type: :consulting) }
    let!(:not_billable_members) { Fabricate.times(10, :team_member, team: team, billable: false, billable_type: nil) }
    let!(:not_active_members) { Fabricate.times(3, :team_member, team: team, billable: false, active: false) }

    it { expect(team.consulting_cost).to eq(consulting_members.sum(&:monthly_payment)) }
  end

  context '#outsourcing_members_billable_count' do
    let(:company) { Fabricate :company }
    let(:team) { Fabricate :team, company: company }
    let!(:members) { Fabricate.times(4, :team_member, team: team, billable_type: :outsourcing) }
    let!(:consulting_members) { Fabricate.times(2, :team_member, team: team, billable_type: :consulting) }
    let!(:not_billable_members) { Fabricate.times(10, :team_member, team: team, billable: false, billable_type: nil) }
    let!(:not_active_members) { Fabricate.times(3, :team_member, team: team, billable: true, billable_type: :outsourcing, active: false) }

    it { expect(team.outsourcing_members_billable_count).to eq 4 }
  end

  context '#consulting_members_billable_count' do
    let(:company) { Fabricate :company }
    let(:team) { Fabricate :team, company: company }
    let!(:members) { Fabricate.times(4, :team_member, team: team, billable_type: :consulting) }
    let!(:consulting_members) { Fabricate.times(2, :team_member, team: team, billable_type: :outsourcing) }
    let!(:not_billable_members) { Fabricate.times(10, :team_member, team: team, billable: false, billable_type: nil) }
    let!(:not_active_members) { Fabricate.times(3, :team_member, team: team, billable: true, billable_type: :consulting, active: false) }

    it { expect(team.consulting_members_billable_count).to eq 4 }
  end

  context '#management_count' do
    let(:company) { Fabricate :company }
    let(:team) { Fabricate :team, company: company }
    let!(:members) { Fabricate.times(4, :team_member, team: team, billable_type: :outsourcing) }
    let!(:consulting_members) { Fabricate.times(2, :team_member, team: team, billable_type: :consulting) }
    let!(:not_billable_members) { Fabricate.times(10, :team_member, team: team, billable: false, billable_type: nil) }
    let!(:not_active_members) { Fabricate.times(3, :team_member, team: team, billable: false, active: false) }

    it { expect(team.management_count).to eq 10 }
  end

  context '#current_outsourcing_monthly_available_hours' do
    let(:company) { Fabricate :company }
    let(:team) { Fabricate :team, company: company }
    let!(:members) { Fabricate.times(4, :team_member, team: team, billable_type: :outsourcing) }
    let!(:consulting_members) { Fabricate.times(2, :team_member, team: team, billable_type: :consulting) }
    let!(:not_billable_members) { Fabricate.times(10, :team_member, team: team, billable: false, billable_type: nil) }
    let!(:not_active_members) { Fabricate.times(3, :team_member, team: team, billable_type: :outsourcing, active: false) }

    it { expect(team.current_outsourcing_monthly_available_hours).to eq(members.sum(&:hours_per_month)) }
  end
end
