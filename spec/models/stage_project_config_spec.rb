# frozen_string_literal: true

RSpec.describe StageProjectConfig, type: :model do
  context 'associations' do
    it { is_expected.to belong_to(:stage) }
    it { is_expected.to belong_to(:project) }
  end

  context 'validations' do
    context 'simple ones' do
      it { is_expected.to validate_presence_of :project }
      it { is_expected.to validate_presence_of :stage }
    end

    context 'complex ones' do
      context 'uniqueness on project and stage' do
        let(:project) { Fabricate :project }
        let(:stage) { Fabricate :stage }
        let!(:stage_project_config) { Fabricate :stage_project_config, project: project, stage: stage }

        context 'having the same project and the same stage' do
          subject(:duplicated_stage_project_config) { Fabricate.build(:stage_project_config, project: project, stage: stage) }
          it 'does not accept the object as valid' do
            expect(duplicated_stage_project_config).not_to be_valid
            expect(duplicated_stage_project_config.errors[:project]).to eq [I18n.t('stage_project_config.validations.stage_project_unique.message')]
          end
        end
        context 'having the same project and different stage' do
          subject(:duplicated_stage_project_config) { Fabricate.build(:stage_project_config, project: project) }
          it { expect(duplicated_stage_project_config).to be_valid }
        end
      end
    end
  end
end
