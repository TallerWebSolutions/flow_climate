# frozen_string_literal: true

RSpec.describe Stage, type: :model do
  context 'enums' do
    it { is_expected.to define_enum_for(:stage_type).with_values(backlog: 0, design: 1, analysis: 2, development: 3, test: 4, homologation: 5, ready_to_deploy: 6, delivered: 7, archived: 8, trashcan: 9) }
    it { is_expected.to define_enum_for(:stage_stream).with_values(upstream: 0, downstream: 1, out_stream: 2) }
    it { is_expected.to define_enum_for(:stage_level).with_values(team: 0, coordination: 1) }
  end

  context 'associations' do
    it { is_expected.to belong_to(:company) }
    it { is_expected.to belong_to(:parent).class_name('Stage').optional(true).inverse_of(:children) }
    it { is_expected.to have_many(:children).class_name('Stage').inverse_of(:parent).dependent(:destroy) }
    it { is_expected.to have_many(:stages_teams).dependent(:restrict_with_error) }
    it { is_expected.to have_many(:teams).through(:stages_teams).dependent(:restrict_with_error) }
    it { is_expected.to have_many(:stage_project_configs) }
    it { is_expected.to have_many(:projects).through(:stage_project_configs) }
    it { is_expected.to have_many(:demand_transitions).dependent(:restrict_with_error) }
    it { is_expected.to have_many(:demand_blocks).dependent(:restrict_with_error) }
    it { is_expected.to have_many(:current_demands).class_name('Demand').inverse_of(:current_stage).dependent(:nullify) }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :name }
    it { is_expected.to validate_presence_of :stage_type }
    it { is_expected.to validate_presence_of :stage_stream }
  end

  describe '#add_project' do
    let(:project) { Fabricate :project }

    context 'when the stage does not have the project yet' do
      let(:stage) { Fabricate :stage }

      before { stage.add_project(project) }

      it { expect(stage.reload.projects).to eq [project] }
    end

    context 'when the stage has the project' do
      let(:stage) { Fabricate :stage, projects: [project] }

      before { stage.add_project(project) }

      it { expect(stage.reload.projects).to eq [project] }
    end
  end

  describe '#remove_project' do
    let(:project) { Fabricate :project }

    context 'when the stage does not have the project yet' do
      let(:stage) { Fabricate :stage }

      before { stage.remove_project(project) }

      it { expect(stage.reload.projects).to eq [] }
    end

    context 'when the stage has the project' do
      let(:stage) { Fabricate :stage, projects: [project] }

      before { stage.remove_project(project) }

      it { expect(stage.reload.projects).to eq [] }
    end
  end

  describe '#add_team' do
    let(:team) { Fabricate :team }

    context 'when the stage does not have the team yet' do
      let(:stage) { Fabricate :stage }

      before { stage.add_team(team) }

      it { expect(stage.reload.teams).to eq [team] }
    end

    context 'when the stage has the team' do
      let(:stage) { Fabricate :stage, teams: [team] }

      before { stage.add_team(team) }

      it { expect(stage.reload.teams).to eq [team] }
    end
  end

  describe '#remove_team' do
    let(:team) { Fabricate :team }

    context 'when the stage does not have the team yet' do
      let(:stage) { Fabricate :stage }

      before { stage.remove_team(team) }

      it { expect(stage.reload.teams).to eq [] }
    end

    context 'when the stage has the team' do
      let(:stage) { Fabricate :stage, teams: [team] }

      before { stage.remove_team(team) }

      it { expect(stage.reload.teams).to eq [] }
    end
  end

  describe '#first_end_stage_in_pipe?' do
    let(:company) { Fabricate :company }
    let(:customer) { Fabricate :customer, company: company }
    let(:project) { Fabricate :project, customers: [customer] }

    let!(:first_stage) { Fabricate :stage, company: company, projects: [project], stage_stream: :downstream, integration_pipe_id: '321', order: 2 }
    let!(:second_stage) { Fabricate :stage, company: company, projects: [project], stage_stream: :downstream, integration_pipe_id: '321', order: 1 }
    let!(:third_stage) { Fabricate :stage, company: company, projects: [project], stage_stream: :downstream, integration_pipe_id: '321', order: 4, end_point: true }
    let!(:fourth_stage) { Fabricate :stage, company: company, projects: [project], stage_stream: :downstream, integration_pipe_id: '321', order: 3, end_point: true }
    let!(:fifth_stage) { Fabricate :stage, company: company, projects: [project], stage_stream: :upstream, integration_pipe_id: '321', order: 2, end_point: false }
    let!(:sixth_stage) { Fabricate :stage, company: company, projects: [project], stage_stream: :downstream, integration_pipe_id: '321', order: -1, end_point: true }

    context 'with data' do
      context 'and the demand reached the downstream' do
        let(:demand) { Fabricate :demand, project: project }
        let!(:first_demand_transition) { Fabricate :demand_transition, stage: first_stage, demand: demand }
        let!(:second_demand_transition) { Fabricate :demand_transition, stage: second_stage, demand: demand }
        let!(:third_demand_transition) { Fabricate :demand_transition, stage: third_stage, demand: demand }
        let!(:fourth_demand_transition) { Fabricate :demand_transition, stage: fourth_stage, demand: demand }
        let!(:fifth_demand_transition) { Fabricate :demand_transition, stage: fifth_stage, demand: demand }

        it 'considers the first end stage in dowsntream as the done' do
          expect(first_stage.first_end_stage_in_pipe?).to be false
          expect(second_stage.first_end_stage_in_pipe?).to be false
          expect(third_stage.first_end_stage_in_pipe?).to be false
          expect(fourth_stage.first_end_stage_in_pipe?).to be true
          expect(fifth_stage.first_end_stage_in_pipe?).to be false
          expect(sixth_stage.first_end_stage_in_pipe?).to be false
        end
      end
    end

    context 'with no data' do
      let!(:first_stage) { Fabricate :stage, company: company }
      let(:demand) { Fabricate :demand, project: project }

      it { expect(first_stage.first_end_stage_in_pipe?).to be false }
    end
  end

  describe '#before_end_point?' do
    let(:company) { Fabricate :company }
    let(:customer) { Fabricate :customer, company: company }
    let(:project) { Fabricate :project, customers: [customer] }

    context 'with data' do
      let!(:first_stage) { Fabricate :stage, company: company, projects: [project], integration_pipe_id: '321', order: 2 }
      let!(:second_stage) { Fabricate :stage, company: company, projects: [project], integration_pipe_id: '321', order: 1 }
      let!(:third_stage) { Fabricate :stage, company: company, projects: [project], integration_pipe_id: '321', order: 4, end_point: true }
      let!(:fourth_stage) { Fabricate :stage, company: company, projects: [project], integration_pipe_id: '321', order: 3, end_point: true }
      let!(:fifth_stage) { Fabricate :stage, company: company, projects: [project], integration_pipe_id: '123', order: 2, end_point: true }

      let(:demand) { Fabricate :demand, project: project }

      let!(:first_demand_transition) { Fabricate :demand_transition, stage: first_stage, demand: demand }
      let!(:second_demand_transition) { Fabricate :demand_transition, stage: second_stage, demand: demand }
      let!(:third_demand_transition) { Fabricate :demand_transition, stage: third_stage, demand: demand }
      let!(:fourth_demand_transition) { Fabricate :demand_transition, stage: fourth_stage, demand: demand }
      let!(:fifth_demand_transition) { Fabricate :demand_transition, stage: fifth_stage, demand: demand }

      it { expect(first_stage.before_end_point?).to be true }
      it { expect(second_stage.before_end_point?).to be true }
      it { expect(third_stage.before_end_point?).to be false }
      it { expect(fourth_stage.before_end_point?).to be false }
      it { expect(fifth_stage.before_end_point?).to be false }
    end

    context 'with no data' do
      let!(:first_stage) { Fabricate :stage, company: company }
      let(:demand) { Fabricate :demand, project: project }

      it { expect(first_stage.before_end_point?).to be true }
    end
  end

  describe '#total_seconds_in' do
    context 'with data' do
      let(:demand) { Fabricate :demand }
      let!(:first_stage) { Fabricate :stage, projects: [demand.project], integration_pipe_id: '321', order: 2 }

      let!(:demand_transition) { Fabricate :demand_transition, demand: demand, stage: first_stage, last_time_in: Time.zone.parse('2018-03-05 22:00'), last_time_out: Time.zone.parse('2018-03-06 13:00') }
      let!(:other_demand_transition) { Fabricate :demand_transition, demand: demand, stage: first_stage, last_time_in: Time.zone.parse('2018-03-07 22:00'), last_time_out: Time.zone.parse('2018-03-09 13:00') }

      it { expect(first_stage.total_seconds_in).to eq 194_400.0 }
    end

    context 'with no data' do
      let!(:first_stage) { Fabricate :stage }

      it { expect(first_stage.total_seconds_in).to eq 0 }
    end
  end

  describe '#commitment_area?' do
    it 'returns true when the stage is in a commitment area within the same integration pipe ID' do
      company = Fabricate :company

      first_stage = Fabricate :stage, company: company, integration_pipe_id: 1, order: 0, commitment_point: false, end_point: false
      second_stage = Fabricate :stage, company: company, integration_pipe_id: 1, order: 1, commitment_point: true, end_point: false
      third_stage = Fabricate :stage, company: company, integration_pipe_id: 1, order: 2, commitment_point: false, end_point: false
      fourth_stage = Fabricate :stage, company: company, integration_pipe_id: 1, order: 3, commitment_point: false, end_point: true
      fifth_stage = Fabricate :stage, company: company, integration_pipe_id: 1, order: 4, commitment_point: false, end_point: false
      sixth_stage = Fabricate :stage, company: company, integration_pipe_id: 1, order: 5, commitment_point: false, end_point: true

      other_company_stage = Fabricate :stage, integration_pipe_id: 1, order: 2, commitment_point: false, end_point: false
      other_pipe_stage = Fabricate :stage, company: company, integration_pipe_id: 2, order: 2, commitment_point: false, end_point: false

      expect(first_stage.commitment_area?).to be false
      expect(second_stage.commitment_area?).to be true
      expect(third_stage.commitment_area?).to be true
      expect(fourth_stage.commitment_area?).to be true
      expect(fifth_stage.commitment_area?).to be false
      expect(sixth_stage.commitment_area?).to be false

      expect(other_company_stage.commitment_area?).to be false
      expect(other_pipe_stage.commitment_area?).to be false
    end
  end
end
