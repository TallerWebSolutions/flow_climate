# frozen_string_literal: true

RSpec.describe Jira::JiraReader do
  let(:company) { Fabricate :company }

  let(:options) { { username: 'foo', password: 'bar', site: 'http://foo.bar', context_path: '/', auth_type: :basic } }
  let(:client) { JIRA::Client.new(options) }

  let(:jira_account) { Fabricate :jira_account, company: company, base_uri: 'http://foo.bar', username: 'foo', api_token: 'bar' }
  let!(:customer_custom_field) { Fabricate :jira_custom_field_mapping, jira_account: jira_account, custom_field_type: :customer, custom_field_machine_name: 'customfield_10013' }
  let!(:contract_custom_field) { Fabricate :jira_custom_field_mapping, jira_account: jira_account, custom_field_type: :contract, custom_field_machine_name: 'customfield_10015' }

  let!(:project) { Fabricate :project, company: company, customers: [customer], products: [product] }

  let(:customer) { Fabricate :customer, company: company, name: 'xpto of bla' }
  let(:product) { Fabricate :product, customer: customer }
  let!(:portfolio_unit) { Fabricate :portfolio_unit, product: product, name: 'statistics' }
  let!(:jira_portfolio_unit_config) { Fabricate :jira_portfolio_unit_config, portfolio_unit: portfolio_unit, jira_field_name: 'module' }

  let!(:jira_product_config) { Fabricate :jira_product_config, product: product, jira_product_key: 'foo' }
  let!(:jira_project_config) { Fabricate :jira_project_config, jira_product_config: jira_product_config, project: project, fix_version_name: 'bar' }

  let!(:jira_issue) { client.Issue.build({ key: '10000', fields: { created: '2018-07-02T11:20:18.998-0300', summary: 'foo of bar', issuetype: { name: 'Story' }, customfield_10028: { value: 'Expedite' }, customfield_10013: { value: 'xpto of bla' }, project: { key: 'foo', self: 'http://foo.bar' }, customfield_10024: [{ emailAddress: 'foo' }, { emailAddress: 'bar' }], fixVersions: [{ name: 'bar' }] }, changelog: { startAt: 0, maxResults: 2, total: 2, histories: [{ id: '10039', created: '2018-07-08T22:34:47.440-0300', items: [{ field: 'status', from: 'first_stage', to: 'second_stage' }] }, { id: '10038', created: '2018-07-06T09:40:43.886-0300', items: [{ field: 'status', from: 'third_stage', to: 'first_stage' }, { field: 'module', toString: 'statistics' }] }] } }.with_indifferent_access) }

  describe '#read_project' do
    it { expect(described_class.instance.read_project(jira_issue.attrs, jira_account)).to eq project }
  end

  describe '#read_product' do
    it { expect(described_class.instance.read_product(jira_issue.attrs, jira_account)).to eq product }
  end

  describe '#read_customer' do
    context 'with an array field' do
      it 'extracts and save the customer' do
        jira_issue = client.Issue.build({ key: '10000', fields: { created: '2018-07-02T11:20:18.998-0300', summary: 'foo of bar', issuetype: { name: 'Story' }, customfield_10028: { value: 'Expedite' }, customfield_10013: [{ value: 'xpto of bla' }], project: { key: 'foo', self: 'http://foo.bar' }, customfield_10024: [{ emailAddress: 'foo' }, { emailAddress: 'bar' }], fixVersions: [{ name: 'bar' }] }, changelog: { startAt: 0, maxResults: 2, total: 2, histories: [{ id: '10039', created: '2018-07-08T22:34:47.440-0300', items: [{ field: 'status', from: 'first_stage', to: 'second_stage' }] }, { id: '10038', created: '2018-07-06T09:40:43.886-0300', items: [{ field: 'status', from: 'third_stage', to: 'first_stage' }, { field: 'module', toString: 'statistics' }] }] } }.with_indifferent_access)
        expect(described_class.instance.read_customer(jira_account, jira_issue.attrs)).to eq customer
      end
    end

    context 'with an simple hash field' do
      it 'extracts and save the customer' do
        jira_issue = client.Issue.build({ key: '10000', fields: { created: '2018-07-02T11:20:18.998-0300', summary: 'foo of bar', issuetype: { name: 'Story' }, customfield_10028: { value: 'Expedite' }, customfield_10013: { value: 'xpto of bla' }, project: { key: 'foo', self: 'http://foo.bar' }, customfield_10024: [{ emailAddress: 'foo' }, { emailAddress: 'bar' }], fixVersions: [{ name: 'bar' }] }, changelog: { startAt: 0, maxResults: 2, total: 2, histories: [{ id: '10039', created: '2018-07-08T22:34:47.440-0300', items: [{ field: 'status', from: 'first_stage', to: 'second_stage' }] }, { id: '10038', created: '2018-07-06T09:40:43.886-0300', items: [{ field: 'status', from: 'third_stage', to: 'first_stage' }, { field: 'module', toString: 'statistics' }] }] } }.with_indifferent_access)
        expect(described_class.instance.read_customer(jira_account, jira_issue.attrs)).to eq customer
      end
    end
  end

  describe '#read_contract' do
    context 'with an array field in the received contract ID' do
      it 'extracts and save the customer' do
        contract = Fabricate :contract, customer: customer
        jira_issue = client.Issue.build({ key: '10000', fields: { created: '2018-07-02T11:20:18.998-0300', summary: 'foo of bar', issuetype: { name: 'Story' }, customfield_10028: { value: 'Expedite' }, customfield_10015: [contract.id], project: { key: 'foo', self: 'http://foo.bar' }, customfield_10024: [{ emailAddress: 'foo' }, { emailAddress: 'bar' }], fixVersions: [{ name: 'bar' }] }, changelog: { startAt: 0, maxResults: 2, total: 2, histories: [{ id: '10039', created: '2018-07-08T22:34:47.440-0300', items: [{ field: 'status', from: 'first_stage', to: 'second_stage' }] }, { id: '10038', created: '2018-07-06T09:40:43.886-0300', items: [{ field: 'status', from: 'third_stage', to: 'first_stage' }, { field: 'module', toString: 'statistics' }] }] } }.with_indifferent_access)
        expect(described_class.instance.read_contract(jira_account, jira_issue.attrs)).to eq contract
      end
    end

    context 'with a string field in the received contract ID' do
      it 'extracts and save the customer' do
        contract = Fabricate :contract, customer: customer
        jira_issue = client.Issue.build({ key: '10000', fields: { created: '2018-07-02T11:20:18.998-0300', summary: 'foo of bar', issuetype: { name: 'Story' }, customfield_10028: { value: 'Expedite' }, customfield_10015: contract.id.to_s, project: { key: 'foo', self: 'http://foo.bar' }, customfield_10024: [{ emailAddress: 'foo' }, { emailAddress: 'bar' }], fixVersions: [{ name: 'bar' }] }, changelog: { startAt: 0, maxResults: 2, total: 2, histories: [{ id: '10039', created: '2018-07-08T22:34:47.440-0300', items: [{ field: 'status', from: 'first_stage', to: 'second_stage' }] }, { id: '10038', created: '2018-07-06T09:40:43.886-0300', items: [{ field: 'status', from: 'third_stage', to: 'first_stage' }, { field: 'module', toString: 'statistics' }] }] } }.with_indifferent_access)
        expect(described_class.instance.read_contract(jira_account, jira_issue.attrs)).to eq contract
      end
    end
  end

  describe '#read_demand_key' do
    it { expect(described_class.instance.read_demand_key(jira_issue.attrs)).to eq '10000' }
  end

  describe '#read_project_url' do
    it { expect(described_class.instance.read_project_url(jira_issue.attrs)).to eq 'http://foo.bar' }
  end

  describe '#read_class_of_service' do
    it { expect(described_class.instance.read_class_of_service(jira_account, jira_issue.attrs, jira_issue.changelog)).to eq :standard }
  end

  describe '#read_portfolio_unit' do
    it { expect(described_class.instance.read_portfolio_unit(jira_issue.changelog, jira_issue.attrs, product)).to eq portfolio_unit }
  end
end
