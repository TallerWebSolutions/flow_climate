# frozen_string_literal: true

RSpec.describe Jira::ProcessJiraProjectJob, type: :active_job do
  describe '.perform_later' do
    it 'enqueues after calling perform_later' do
      described_class.perform_later(bla: 'foo')
      expect(described_class).to have_been_enqueued.on_queue('project_update')
    end
  end

  describe '.perform' do
    context 'having params' do
      let(:options) { { username: 'foo', password: 'bar', site: 'http://foo.bar', context_path: '/', auth_type: :basic } }
      let(:client) { JIRA::Client.new(options) }

      let(:jira_project) { client.Project.build({ key: 'FC', name: 'Example', projectTypeKey: 'business', lead: 'username' }.with_indifferent_access) }
      let!(:jira_issue) { client.Issue.build({ key: '10000', summary: 'foo of bar', fields: { created: '2018-07-02T11:20:18.998-0300', issuetype: { name: 'Story' }, customfield_10028: { value: 'Expedite' }, project: { key: 'FC' }, customfield_10024: [{ name: 'foo' }, { name: 'bar' }] }, changelog: { startAt: 0, maxResults: 2, total: 2, histories: [{ id: '10039', from: 'first_stage', to: 'second_stage', created: '2018-07-08T22:34:47.440-0300' }, { id: '10038', from: 'third_stage', to: 'first_stage', created: '2018-07-06T09:40:43.886-0300' }] } }.with_indifferent_access) }
      let(:jira_account) { Fabricate :jira_account, base_uri: 'http://foo.bar', username: 'foo', api_token: 'bar', customer_domain: 'xpto' }
      let(:product) { Fabricate :product }
      let(:project) { Fabricate :project, products: [product] }
      let!(:jira_product_config) { Fabricate :jira_product_config, product: product, jira_product_key: 'FC' }

      let!(:jira_config) { Fabricate :jira_project_config, jira_product_config: jira_product_config, project: project }

      let(:team) { Fabricate :team }

      context 'valid responses' do
        context 'and a jira config' do
          context 'and demand' do
            it 'calls the adapter to translation' do
              allow_any_instance_of(Jira::JiraApiService).to(receive(:request_issues_by_fix_version) { [jira_issue] })
              allow_any_instance_of(Jira::JiraApiService).to(receive(:request_issue_changelog).with('10000') { jira_issue })
              expect(Jira::ProcessJiraIssueJob).to receive(:perform_later).once
              described_class.perform_now(jira_account, jira_config, 'foo@bar.com', 'Foo Bar', 'http://foo.com.br')
            end
          end
        end
      end

      context 'and invalid data' do
        context 'and blank issue response' do
          let(:jira_issue) { client.Issue.build }

          it 'returns doing nothing' do
            allow_any_instance_of(Jira::JiraApiService).to(receive(:request_issues_by_fix_version) { [jira_issue] })
            expect_any_instance_of(Jira::JiraApiService).not_to(receive(:request_issue_changelog))
            expect(Jira::JiraIssueAdapter.instance).not_to receive(:process_issue)
            described_class.perform_now(jira_account, jira_config, 'foo@bar.com', 'Foo Bar', 'http://foo.com.br')
          end
        end
      end
    end
  end
end
