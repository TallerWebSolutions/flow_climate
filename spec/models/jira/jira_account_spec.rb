# frozen_string_literal: true

RSpec.describe Jira::JiraAccount, type: :model do
  context 'associations' do
    it { is_expected.to belong_to :company }
    it { is_expected.to have_many(:jira_custom_field_mappings).dependent(:destroy) }
  end

  context 'validations' do
    context 'simple ones' do
      it { is_expected.to validate_presence_of :company }
      it { is_expected.to validate_presence_of :username }
      it { is_expected.to validate_presence_of :password }
      it { is_expected.to validate_presence_of :base_uri }
      it { is_expected.to validate_presence_of :customer_domain }
    end

    context 'complex ones' do
      context 'customer_domain' do
        let!(:jira_account) { Fabricate :jira_account, customer_domain: 'foo' }
        let!(:other_jira_account) { Fabricate.build :jira_account, customer_domain: 'foo' }

        it 'responds invalid with an error message' do
          expect(other_jira_account).not_to be_valid
          expect(other_jira_account.errors.full_messages).to eq ['Domínio do Usuário já está em uso']
        end
      end
    end
  end

  context 'attr encryption' do
    it 'encrypts the password' do
      jira_account = Fabricate :jira_account, password: '123'
      expect(jira_account.encrypted_password).not_to eq '123'
    end
  end

  describe '#responsibles_custom_field' do
    let(:jira_account) { Fabricate :jira_account }

    context 'having the custom fields' do
      let!(:responsibles_jira_custom_field_mapping) { Fabricate :jira_custom_field_mapping, jira_account: jira_account, demand_field: :responsibles }
      let!(:class_of_service_custom_field_mapping) { Fabricate :jira_custom_field_mapping, jira_account: jira_account, demand_field: :class_of_service }

      it { expect(jira_account.responsibles_custom_field).to eq responsibles_jira_custom_field_mapping }
    end

    context 'having the custom fields but not having a field to responsibles' do
      let!(:class_of_service_custom_field_mapping) { Fabricate :jira_custom_field_mapping, jira_account: jira_account, demand_field: :class_of_service }

      it { expect(jira_account.responsibles_custom_field).to be_nil }
    end

    context 'having no custom fields' do
      it { expect(jira_account.responsibles_custom_field).to be_nil }
    end
  end

  describe '#class_of_service_custom_field' do
    let(:jira_account) { Fabricate :jira_account }

    context 'having the custom fields' do
      let!(:responsibles_jira_custom_field_mapping) { Fabricate :jira_custom_field_mapping, jira_account: jira_account, demand_field: :responsibles }
      let!(:class_of_service_custom_field_mapping) { Fabricate :jira_custom_field_mapping, jira_account: jira_account, demand_field: :class_of_service }

      it { expect(jira_account.class_of_service_custom_field).to eq class_of_service_custom_field_mapping }
    end

    context 'having the custom fields but not having a field to responsibles' do
      let!(:class_of_service_custom_field_mapping) { Fabricate :jira_custom_field_mapping, jira_account: jira_account, demand_field: :responsibles }

      it { expect(jira_account.class_of_service_custom_field).to be_nil }
    end

    context 'having no custom fields' do
      it { expect(jira_account.class_of_service_custom_field).to be_nil }
    end
  end
end
