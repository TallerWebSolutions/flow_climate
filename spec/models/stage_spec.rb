# frozen_string_literal: true

RSpec.describe Stage, type: :model do
  context 'enums' do
    it { is_expected.to define_enum_for(:stage_type).with_values(backlog: 0, design: 1, analysis: 2, development: 3, test: 4, homologation: 5, ready_to_deploy: 6, delivered: 7, archived: 8) }
    it { is_expected.to define_enum_for(:stage_stream).with_values(upstream: 0, downstream: 1, out_stream: 2) }
  end

  context 'associations' do
    it { is_expected.to belong_to(:company) }
    it { is_expected.to belong_to(:team) }
    it { is_expected.to have_many(:stage_project_configs) }
    it { is_expected.to have_many(:projects).through(:stage_project_configs) }
    it { is_expected.to have_many(:demand_transitions).dependent(:restrict_with_error) }
    it { is_expected.to have_many(:demand_blocks).dependent(:restrict_with_error) }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :integration_id }
    it { is_expected.to validate_presence_of :name }
    it { is_expected.to validate_presence_of :stage_type }
    it { is_expected.to validate_presence_of :stage_stream }
  end

  describe '#add_project!' do
    let(:project) { Fabricate :project }

    context 'when the stage does not have the project yet' do
      let(:stage) { Fabricate :stage }

      before { stage.add_project!(project) }

      it { expect(stage.reload.projects).to eq [project] }
    end

    context 'when the stage has the project' do
      let(:stage) { Fabricate :stage, projects: [project] }

      before { stage.add_project!(project) }

      it { expect(stage.reload.projects).to eq [project] }
    end
  end

  describe '#remove_project!' do
    let(:project) { Fabricate :project }

    context 'when the stage does not have the project yet' do
      let(:stage) { Fabricate :stage }

      before { stage.remove_project!(project) }

      it { expect(stage.reload.projects).to eq [] }
    end

    context 'when the stage has the project' do
      let(:stage) { Fabricate :stage, projects: [project] }

      before { stage.remove_project!(project) }

      it { expect(stage.reload.projects).to eq [] }
    end
  end

  describe '#first_end_stage_in_pipe?' do
    let(:company) { Fabricate :company }
    let(:customer) { Fabricate :customer, company: company }
    let(:project) { Fabricate :project, customer: customer }

    let!(:first_stage) { Fabricate :stage, company: company, projects: [project], stage_stream: :downstream, integration_pipe_id: '321', order: 2 }
    let!(:second_stage) { Fabricate :stage, company: company, projects: [project], stage_stream: :downstream, integration_pipe_id: '321', order: 1 }
    let!(:third_stage) { Fabricate :stage, company: company, projects: [project], stage_stream: :downstream, integration_pipe_id: '321', order: 4, end_point: true }
    let!(:fourth_stage) { Fabricate :stage, company: company, projects: [project], stage_stream: :downstream, integration_pipe_id: '321', order: 3, end_point: true }
    let!(:fifth_stage) { Fabricate :stage, company: company, projects: [project], stage_stream: :upstream, integration_pipe_id: '321', order: 2, end_point: true }

    context 'having data' do
      context 'and the demand reached the downstream' do
        let(:demand) { Fabricate :demand, project: project }
        let!(:first_demand_transition) { Fabricate :demand_transition, stage: first_stage, demand: demand }
        let!(:second_demand_transition) { Fabricate :demand_transition, stage: second_stage, demand: demand }
        let!(:third_demand_transition) { Fabricate :demand_transition, stage: third_stage, demand: demand }
        let!(:fourth_demand_transition) { Fabricate :demand_transition, stage: fourth_stage, demand: demand }
        let!(:fifth_demand_transition) { Fabricate :demand_transition, stage: fifth_stage, demand: demand }

        it 'considers the first end stage in dowsntream as the done' do
          expect(first_stage.first_end_stage_in_pipe?(demand)).to be false
          expect(second_stage.first_end_stage_in_pipe?(demand)).to be false
          expect(third_stage.first_end_stage_in_pipe?(demand)).to be false
          expect(fourth_stage.first_end_stage_in_pipe?(demand)).to be true
          expect(fifth_stage.first_end_stage_in_pipe?(demand)).to be false
        end
      end

      context 'and the demand did not reach the downstream' do
        let(:demand) { Fabricate :demand, project: project }
        let!(:fifth_demand_transition) { Fabricate :demand_transition, stage: fifth_stage, demand: demand }

        it 'considers the first end stage in upstream as the done' do
          expect(first_stage.first_end_stage_in_pipe?(demand)).to be false
          expect(second_stage.first_end_stage_in_pipe?(demand)).to be false
          expect(third_stage.first_end_stage_in_pipe?(demand)).to be false
          expect(fourth_stage.first_end_stage_in_pipe?(demand)).to be false
          expect(fifth_stage.first_end_stage_in_pipe?(demand)).to be true
        end
      end
    end

    context 'having no data' do
      let!(:first_stage) { Fabricate :stage, company: company }
      let(:demand) { Fabricate :demand, project: project }

      it { expect(first_stage.first_end_stage_in_pipe?(demand)).to be false }
    end
  end

  describe '#before_end_point?' do
    let(:company) { Fabricate :company }
    let(:customer) { Fabricate :customer, company: company }
    let(:project) { Fabricate :project, customer: customer }

    context 'having data' do
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

      it { expect(first_stage.before_end_point?(demand)).to be true }
      it { expect(second_stage.before_end_point?(demand)).to be true }
      it { expect(third_stage.before_end_point?(demand)).to be false }
      it { expect(fourth_stage.before_end_point?(demand)).to be false }
      it { expect(fifth_stage.before_end_point?(demand)).to be false }
    end

    context 'having no data' do
      let!(:first_stage) { Fabricate :stage, company: company }
      let(:demand) { Fabricate :demand, project: project }

      it { expect(first_stage.before_end_point?(demand)).to be true }
    end
  end
end
