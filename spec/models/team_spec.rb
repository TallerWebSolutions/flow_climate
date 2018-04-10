# frozen_string_literal: true

RSpec.describe Team, type: :model do
  context 'associations' do
    it { is_expected.to belong_to :company }
    it { is_expected.to have_many(:team_members).dependent(:restrict_with_error) }
    it { is_expected.to have_many(:products).dependent(:restrict_with_error) }
    it { is_expected.to have_many(:project_results).dependent(:restrict_with_error) }
    it { is_expected.to have_many(:projects).through(:project_results) }
    it { is_expected.to have_many(:pipefy_team_configs).dependent(:destroy) }
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

  describe '#active_cost_for_billable_types' do
    let(:company) { Fabricate :company }
    let(:team) { Fabricate :team, company: company }
    let!(:members) { Fabricate.times(4, :team_member, team: team, billable_type: :outsourcing) }
    let!(:consulting_members) { Fabricate.times(2, :team_member, team: team, billable_type: :consulting) }
    let!(:training_members) { Fabricate.times(6, :team_member, team: team, billable_type: :training) }
    let!(:not_billable_members) { Fabricate.times(10, :team_member, team: team, billable: false, billable_type: nil) }
    let!(:not_active_members) { Fabricate.times(3, :team_member, team: team, billable: true, billable_type: :outsourcing, active: false) }

    it { expect(team.active_cost_for_billable_types(%i[outsourcing consulting])).to eq(members.concat(consulting_members).sum(&:total_monthly_payment)) }
  end

  describe '#active_members_count_for_billable_types' do
    let(:company) { Fabricate :company }
    let(:team) { Fabricate :team, company: company }
    let!(:members) { Fabricate.times(4, :team_member, team: team, billable_type: :outsourcing) }
    let!(:consulting_members) { Fabricate.times(2, :team_member, team: team, billable_type: :consulting) }
    let!(:training_members) { Fabricate.times(6, :team_member, team: team, billable_type: :training) }
    let!(:not_billable_members) { Fabricate.times(10, :team_member, team: team, billable: false, billable_type: nil) }
    let!(:not_active_members) { Fabricate.times(3, :team_member, team: team, billable: true, billable_type: :outsourcing, active: false) }

    it { expect(team.active_members_count_for_billable_types(%i[consulting outsourcing])).to eq 6 }
  end

  describe '#active_available_hours_for_billable_types' do
    let(:company) { Fabricate :company }
    let(:team) { Fabricate :team, company: company }
    let!(:members) { Fabricate.times(4, :team_member, team: team, billable_type: :outsourcing) }
    let!(:consulting_members) { Fabricate.times(2, :team_member, team: team, billable_type: :consulting) }
    let!(:training_members) { Fabricate.times(6, :team_member, team: team, billable_type: :training) }
    let!(:not_billable_members) { Fabricate.times(10, :team_member, team: team, billable: false, billable_type: nil) }
    let!(:not_active_members) { Fabricate.times(3, :team_member, team: team, billable_type: :outsourcing, active: false) }

    it { expect(team.active_available_hours_for_billable_types(%i[outsourcing consulting])).to eq members.concat(consulting_members).sum(&:hours_per_month) }
  end

  RSpec.shared_context 'consolidations data for team', shared_context: :metadata do
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
    include_context 'consolidations data for team'
    it { expect(team.last_week_scope).to eq 15 }
  end

  describe '#avg_hours_per_demand' do
    include_context 'consolidations data for team'
    it { expect(team.avg_hours_per_demand).to eq team.projects.sum(&:avg_hours_per_demand) / team.projects_count.to_f }
  end

  describe '#total_value' do
    include_context 'consolidations data for team'
    it { expect(team.total_value).to eq team.projects.sum(:value) }
  end

  describe '#remaining_money' do
    include_context 'consolidations data for team'
    it { expect(team.remaining_money).to eq team.projects.sum(&:remaining_money) }
  end

  describe '#percentage_remaining_money' do
    context 'having data' do
      include_context 'consolidations data for team'
      it { expect(team.percentage_remaining_money).to eq((team.remaining_money / team.total_value) * 100) }
    end
    context 'having no data' do
      let(:company) { Fabricate :company }
      let(:team) { Fabricate :team, company: company }

      it { expect(team.percentage_remaining_money).to eq 0 }
    end
  end

  describe '#total_gap' do
    include_context 'consolidations data for team'
    it { expect(team.total_gap).to eq team.projects.sum(&:total_gap) }
  end

  describe '#percentage_remaining_scope' do
    context 'having data' do
      include_context 'consolidations data for team'
      it { expect(team.percentage_remaining_scope).to eq((team.total_gap.to_f / team.last_week_scope.to_f) * 100) }
    end
    context 'having no data' do
      let(:company) { Fabricate :company }
      let(:team) { Fabricate :team, company: company }

      it { expect(team.percentage_remaining_scope).to eq 0 }
    end
  end

  describe '#total_flow_pressure' do
    include_context 'consolidations data for team'
    it { expect(team.total_flow_pressure).to eq team.projects.sum(&:flow_pressure) }
  end

  describe '#delivered_scope' do
    include_context 'consolidations data for team'
    it { expect(team.delivered_scope).to eq team.projects.sum(&:total_throughput) }
  end

  describe '#total_cost' do
    let(:team) { Fabricate :team }
    let!(:team_member) { Fabricate :team_member, team: team, monthly_payment: 100 }
    let!(:other_team_member) { Fabricate :team_member, team: team, monthly_payment: 100 }

    it { expect(team.total_cost).to eq team.team_members.sum(&:total_monthly_payment) }
  end

  describe '#consumed_hours_in_month' do
    before { travel_to Time.zone.local(2018, 4, 6, 10, 0, 0) }
    after { travel_back }

    let(:team) { Fabricate :team }
    context 'having project results' do
      let!(:project_result) { Fabricate :project_result, team: team, qty_hours_downstream: 200, qty_hours_upstream: 87 }
      let!(:other_project_result) { Fabricate :project_result, team: team, qty_hours_downstream: 130, qty_hours_upstream: 65 }

      it { expect(team.consumed_hours_in_month(Time.zone.today)).to eq 482 }
    end

    context 'having no project results' do
      it { expect(team.consumed_hours_in_month(Time.zone.today)).to eq 0 }
    end
  end
end
