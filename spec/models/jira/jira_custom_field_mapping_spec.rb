# frozen_string_literal: true

RSpec.describe Jira::JiraCustomFieldMapping, type: :model do
  context 'enums' do
    it { is_expected.to define_enum_for(:demand_field).with(class_of_service: 0, responsibles: 1) }
  end

  context 'associations' do
    it { is_expected.to belong_to :jira_account }
  end

  context 'validations' do
    context 'complex ones' do
      context 'demand_field uniqueness' do
        let!(:jira_account) { Fabricate :jira_account }
        let!(:jira_custom_field_mapping) { Fabricate :jira_custom_field_mapping, jira_account: jira_account, demand_field: :responsibles }

        context 'same demand_field in same jira account' do
          let!(:other_custom_field) { Fabricate.build :jira_custom_field_mapping, jira_account: jira_account, demand_field: :responsibles }
          it 'does not accept the model' do
            expect(other_custom_field.valid?).to be false
            expect(other_custom_field.errors[:demand_field]).to eq [I18n.t('jira_custom_field_mapping.uniqueness.demand_field')]
          end
        end
        context 'other demand_field in same jira_account' do
          let!(:other_custom_field) { Fabricate.build :jira_custom_field_mapping, jira_account: jira_account, demand_field: :class_of_service }
          it { expect(other_custom_field.valid?).to be true }
        end
        context 'same demand_field in different jira_account' do
          let!(:other_custom_field) { Fabricate.build :jira_custom_field_mapping, demand_field: :responsibles }
          it { expect(other_custom_field.valid?).to be true }
        end
      end
    end

    context 'simple ones' do
      it { is_expected.to validate_presence_of :jira_account }
      it { is_expected.to validate_presence_of :custom_field_machine_name }
      it { is_expected.to validate_presence_of :demand_field }
    end
  end
end
