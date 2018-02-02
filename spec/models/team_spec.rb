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

    context 'complex ones' do
      let(:company) { Fabricate :company }

      context 'uniqueness' do
        context 'same name in same customer' do
          let!(:team) { Fabricate :team, company: company, name: 'zzz' }
          let!(:other_team) { Fabricate.build :team, company: company, name: 'zzz' }
          it 'does not accept the model' do
            expect(other_team.valid?).to be false
            expect(other_team.errors[:name]).to eq ['Não deve repetir nome do time para a mesma empresa.']
          end
        end
        context 'different name in same customer' do
          let!(:team) { Fabricate :team, company: company, name: 'zzz' }
          let!(:other_team) { Fabricate.build :team, company: company, name: 'aaa' }
          it { expect(other_team.valid?).to be true }
        end
        context 'different name in same customer' do
          let!(:team) { Fabricate :team, company: company, name: 'zzz' }
          let!(:other_team) { Fabricate.build :team, name: 'zzz' }
          it { expect(other_team.valid?).to be true }
        end
      end
    end
  end

  context 'delegations' do
    it { is_expected.to delegate_method(:count).to(:projects).with_prefix }
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

  RSpec.shared_context 'consolidations variables data for team', shared_context: :metadata do
    let(:company) { Fabricate :company }

    let(:team) { Fabricate :team, company: company }
    let(:other_team) { Fabricate :team, company: company }

    let(:product) { Fabricate :product, name: 'zzz' }
    let(:other_product) { Fabricate :product, name: 'zzz' }

    let(:project) { Fabricate :project }
    let(:other_project) { Fabricate :project }
    let(:other_customer_project) { Fabricate :project }

    let!(:first_result) { Fabricate :project_result, project: project, team: team, result_date: 1.week.ago, known_scope: 10 }
    let!(:second_result) { Fabricate :project_result, project: project, team: team, result_date: 1.week.ago, known_scope: 20 }
    let!(:third_result) { Fabricate :project_result, project: other_project, team: team, result_date: 1.week.ago, known_scope: 5 }
    let!(:fourth_result) { Fabricate :project_result, project: other_customer_project, team: other_team, result_date: 1.week.ago, known_scope: 50 }
  end

  describe '#last_week_scope' do
    include_context 'consolidations variables data for team'
    it { expect(team.last_week_scope).to eq 15 }
  end

  describe '#avg_hours_per_demand' do
    include_context 'consolidations variables data for team'
    it { expect(team.avg_hours_per_demand).to eq team.projects.sum(&:avg_hours_per_demand) / team.projects_count.to_f }
  end

  describe '#total_value' do
    include_context 'consolidations variables data for team'
    it { expect(team.total_value).to eq team.projects.sum(:value) }
  end

  describe '#remaining_money' do
    include_context 'consolidations variables data for team'
    it { expect(team.remaining_money).to eq team.projects.sum(&:remaining_money) }
  end

  describe '#percentage_remaining_money' do
    context 'having data' do
      include_context 'consolidations variables data for team'
      it { expect(team.percentage_remaining_money).to eq((team.remaining_money / team.total_value) * 100) }
    end
    context 'having no data' do
      let(:company) { Fabricate :company }
      let(:team) { Fabricate :team, company: company }

      it { expect(team.percentage_remaining_money).to eq 0 }
    end
  end

  describe '#total_gap' do
    include_context 'consolidations variables data for team'
    it { expect(team.total_gap).to eq team.projects.sum(&:total_gap) }
  end

  describe '#percentage_remaining_scope' do
    context 'having data' do
      include_context 'consolidations variables data for team'
      it { expect(team.percentage_remaining_scope).to eq((team.total_gap.to_f / team.last_week_scope.to_f) * 100) }
    end
    context 'having no data' do
      let(:company) { Fabricate :company }
      let(:team) { Fabricate :team, company: company }

      it { expect(team.percentage_remaining_scope).to eq 0 }
    end
  end

  describe '#total_flow_pressure' do
    include_context 'consolidations variables data for team'
    it { expect(team.total_flow_pressure).to eq team.projects.sum(&:flow_pressure) }
  end

  describe '#delivered_scope' do
    include_context 'consolidations variables data for team'
    it { expect(team.delivered_scope).to eq team.projects.sum(&:total_throughput) }
  end
end
