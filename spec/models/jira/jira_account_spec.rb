# frozen_string_literal: true

RSpec.describe Jira::JiraAccount, type: :model do
  context 'associations' do
    it { is_expected.to belong_to :company }
    it { is_expected.to have_many(:jira_custom_field_mappings).dependent(:destroy) }
  end

  context 'validations' do
    context 'simple ones' do
      it { is_expected.to validate_presence_of :username }
      it { is_expected.to validate_presence_of :encrypted_api_token }
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

      context 'base_uri' do
        let!(:jira_account) { Fabricate :jira_account, base_uri: 'foo' }
        let!(:other_jira_account) { Fabricate.build :jira_account, base_uri: 'foo' }

        it 'responds invalid with an error message' do
          expect(other_jira_account).not_to be_valid
          expect(other_jira_account.errors.full_messages).to eq ['URI base já está em uso']
        end
      end
    end
  end

  context 'attr encryption' do
    it 'encrypts the api_token' do
      jira_account = Fabricate :jira_account, api_token: '123'
      expect(jira_account.encrypted_api_token).not_to eq '123'
    end
  end

  describe '#responsibles_custom_field' do
    let(:jira_account) { Fabricate :jira_account }

    context 'having the custom fields' do
      let!(:responsibles_jira_custom_field_mapping) { Fabricate :jira_custom_field_mapping, jira_account: jira_account, custom_field_type: :responsibles }
      let!(:class_of_service_custom_field_mapping) { Fabricate :jira_custom_field_mapping, jira_account: jira_account, custom_field_type: :class_of_service }

      it { expect(jira_account.responsibles_custom_field).to eq responsibles_jira_custom_field_mapping }
    end

    context 'having the custom fields but not having a field to responsibles' do
      let!(:class_of_service_custom_field_mapping) { Fabricate :jira_custom_field_mapping, jira_account: jira_account, custom_field_type: :class_of_service }

      it { expect(jira_account.responsibles_custom_field).to be_nil }
    end

    context 'having no custom fields' do
      it { expect(jira_account.responsibles_custom_field).to be_nil }
    end
  end

  describe '#class_of_service_custom_field' do
    let(:jira_account) { Fabricate :jira_account }

    context 'having the custom fields' do
      let!(:responsibles_jira_custom_field_mapping) { Fabricate :jira_custom_field_mapping, jira_account: jira_account, custom_field_type: :responsibles }
      let!(:class_of_service_custom_field_mapping) { Fabricate :jira_custom_field_mapping, jira_account: jira_account, custom_field_type: :class_of_service }

      it { expect(jira_account.class_of_service_custom_field).to eq class_of_service_custom_field_mapping }
    end

    context 'having the custom fields but not having a field to class of service' do
      let!(:responsibles_jira_custom_field_mapping) { Fabricate :jira_custom_field_mapping, jira_account: jira_account, custom_field_type: :responsibles }

      it { expect(jira_account.class_of_service_custom_field).to be_nil }
    end

    context 'having no custom fields' do
      it { expect(jira_account.class_of_service_custom_field).to be_nil }
    end
  end

  describe '#customer_custom_field' do
    let(:jira_account) { Fabricate :jira_account }

    context 'having the custom fields' do
      let!(:customer_custom_field) { Fabricate :jira_custom_field_mapping, jira_account: jira_account, custom_field_type: :customer }
      let!(:class_of_service_custom_field_mapping) { Fabricate :jira_custom_field_mapping, jira_account: jira_account, custom_field_type: :class_of_service }

      it { expect(jira_account.customer_custom_field).to eq customer_custom_field }
    end

    context 'having the custom fields but not having a field to customer' do
      let!(:responsibles_jira_custom_field_mapping) { Fabricate :jira_custom_field_mapping, jira_account: jira_account, custom_field_type: :responsibles }

      it { expect(jira_account.customer_custom_field).to be_nil }
    end

    context 'having no custom fields' do
      it { expect(jira_account.customer_custom_field).to be_nil }
    end
  end

  describe '#contract_custom_field' do
    let(:jira_account) { Fabricate :jira_account }

    context 'having the custom fields' do
      let!(:contract_custom_field) { Fabricate :jira_custom_field_mapping, jira_account: jira_account, custom_field_type: :contract }
      let!(:class_of_service_custom_field_mapping) { Fabricate :jira_custom_field_mapping, jira_account: jira_account, custom_field_type: :class_of_service }

      it { expect(jira_account.contract_custom_field).to eq contract_custom_field }
    end

    context 'having the custom fields but not having a field to contract' do
      let!(:responsibles_jira_custom_field_mapping) { Fabricate :jira_custom_field_mapping, jira_account: jira_account, custom_field_type: :responsibles }

      it { expect(jira_account.contract_custom_field).to be_nil }
    end

    context 'having no custom fields' do
      it { expect(jira_account.customer_custom_field).to be_nil }
    end
  end
end
