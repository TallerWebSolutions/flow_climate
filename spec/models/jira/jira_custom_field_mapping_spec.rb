# frozen_string_literal: true

RSpec.describe Jira::JiraCustomFieldMapping, type: :model do
  context 'enums' do
    it { is_expected.to define_enum_for(:custom_field_type).with_values(class_of_service: 0, responsibles: 1) }
  end

  context 'associations' do
    it { is_expected.to belong_to :jira_account }
  end

  context 'validations' do
    context 'complex ones' do
      context 'custom_field_type uniqueness' do
        let!(:jira_account) { Fabricate :jira_account }
        let!(:jira_custom_field_mapping) { Fabricate :jira_custom_field_mapping, jira_account: jira_account, custom_field_type: :responsibles }

        context 'same custom_field_type in same jira account' do
          let!(:other_custom_field) { Fabricate.build :jira_custom_field_mapping, jira_account: jira_account, custom_field_type: :responsibles }

          it 'does not accept the model' do
            expect(other_custom_field.valid?).to be false
            expect(other_custom_field.errors[:custom_field_type]).to eq [I18n.t('jira_custom_field_mapping.uniqueness.custom_field_type')]
          end
        end

        context 'other custom_field_type in same jira_account' do
          let!(:other_custom_field) { Fabricate.build :jira_custom_field_mapping, jira_account: jira_account, custom_field_type: :class_of_service }

          it { expect(other_custom_field.valid?).to be true }
        end

        context 'same custom_field_type in different jira_account' do
          let!(:other_custom_field) { Fabricate.build :jira_custom_field_mapping, custom_field_type: :responsibles }

          it { expect(other_custom_field.valid?).to be true }
        end
      end
    end

    context 'simple ones' do
      it { is_expected.to validate_presence_of :jira_account }
      it { is_expected.to validate_presence_of :custom_field_machine_name }
      it { is_expected.to validate_presence_of :custom_field_type }
    end
  end
end
