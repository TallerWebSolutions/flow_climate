# frozen_string_literal: true

RSpec.describe Stage, type: :model do
  context 'enums' do
    it { is_expected.to define_enum_for(:stage_type).with(backlog: 0, design: 1, analysis: 2, development: 3, test: 4, homologation: 5, ready_to_deploy: 6, delivered: 7) }
    it { is_expected.to define_enum_for(:stage_stream).with(upstream: 0, downstream: 1) }
  end

  context 'associations' do
    it { is_expected.to belong_to(:company) }
    it { is_expected.to have_and_belong_to_many(:projects) }
    it { is_expected.to have_many(:demand_transitions).dependent(:restrict_with_error) }
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
end
