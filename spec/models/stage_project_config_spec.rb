# frozen_string_literal: true

RSpec.describe StageProjectConfig, type: :model do
  context 'associations' do
    it { is_expected.to belong_to(:stage) }
    it { is_expected.to belong_to(:project) }
  end

  context 'validations' do
    context 'simple ones' do
      it { is_expected.to validate_presence_of :stage_percentage }
      it { is_expected.to validate_presence_of :pairing_percentage }
      it { is_expected.to validate_presence_of :management_percentage }
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

  describe '#pairing_percentage_decimal' do
    let!(:stage_project_config) { Fabricate :stage_project_config, pairing_percentage: 30 }
    let!(:blank_pairing_percentage_stage_project_config) { Fabricate :stage_project_config, pairing_percentage: 0 }

    it { expect(stage_project_config.pairing_percentage_decimal).to eq 0.3 }
    it { expect(blank_pairing_percentage_stage_project_config.pairing_percentage_decimal).to eq 0 }
  end

  describe '#management_percentage_decimal' do
    let!(:stage_project_config) { Fabricate :stage_project_config, management_percentage: 50 }

    it { expect(stage_project_config.management_percentage_decimal).to eq 0.5 }
  end

  describe '#stage_percentage_decimal' do
    let!(:stage_project_config) { Fabricate :stage_project_config, stage_percentage: 90 }

    it { expect(stage_project_config.stage_percentage_decimal).to eq 0.9 }
  end
end
