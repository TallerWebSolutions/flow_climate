# frozen_string_literal: true

RSpec.describe Jira::JiraReader do
  let(:company) { Fabricate :company }

  let(:options) { { username: 'foo', password: 'bar', site: 'http://foo.bar', context_path: '/', auth_type: :basic, read_timeout: 120 } }
  let(:client) { JIRA::Client.new(options) }

  let(:jira_account) { Fabricate :jira_account, company: company, base_uri: 'http://foo.bar', username: 'foo', api_token: 'bar' }

  let!(:project) { Fabricate :project, company: company, customers: [customer], products: [product] }

  let(:customer) { Fabricate :customer, company: company }
  let(:product) { Fabricate :product, customer: customer }
  let!(:portfolio_unit) { Fabricate :portfolio_unit, product: product, name: 'statistics' }
  let!(:jira_portfolio_unit_config) { Fabricate :jira_portfolio_unit_config, portfolio_unit: portfolio_unit, jira_field_name: 'module' }

  let!(:jira_product_config) { Fabricate :jira_product_config, product: product, jira_product_key: 'foo' }
  let!(:jira_project_config) { Fabricate :jira_project_config, jira_product_config: jira_product_config, project: project, fix_version_name: 'bar' }

  let!(:jira_issue) { client.Issue.build({ key: '10000', fields: { created: '2018-07-02T11:20:18.998-0300', summary: 'foo of bar', issuetype: { name: 'Story' }, customfield_10028: { value: 'Expedite' }, project: { key: 'foo', self: 'http://foo.bar' }, customfield_10024: [{ emailAddress: 'foo' }, { emailAddress: 'bar' }], fixVersions: [{ name: 'bar' }] }, changelog: { startAt: 0, maxResults: 2, total: 2, histories: [{ id: '10039', created: '2018-07-08T22:34:47.440-0300', items: [{ field: 'status', from: 'first_stage', to: 'second_stage' }] }, { id: '10038', created: '2018-07-06T09:40:43.886-0300', items: [{ field: 'status', from: 'third_stage', to: 'first_stage' }, { field: 'module', toString: 'statistics' }] }] } }.with_indifferent_access) }

  describe '#read_project' do
    it { expect(described_class.instance.read_project(jira_issue.attrs, jira_account)).to eq project }
  end

  describe '#read_product' do
    it { expect(described_class.instance.read_product(jira_issue.attrs, jira_account)).to eq product }
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
