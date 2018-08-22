# frozen_string_literal: true

RSpec.describe Jira::ProcessJiraProjectJob, type: :active_job do
  describe '.perform_later' do
    it 'enqueues after calling perform_later' do
      Jira::ProcessJiraProjectJob.perform_later(bla: 'foo')
      expect(Jira::ProcessJiraProjectJob).to have_been_enqueued.on_queue('default')
    end
  end

  describe '.perform' do
    context 'having params' do
      let(:options) { { username: 'foo', password: 'bar', site: 'http://foo.bar', context_path: '/', auth_type: :basic, read_timeout: 120 } }
      let(:client) { JIRA::Client.new(options) }

      let(:jira_project) { client.Project.build({ key: 'FC', name: 'Example', projectTypeKey: 'business', lead: 'username' }.with_indifferent_access) }
      let!(:jira_issue) { client.Issue.build({ key: '10000', summary: 'foo of bar', fields: { created: '2018-07-02T11:20:18.998-0300', issuetype: { name: 'Story' }, customfield_10028: { value: 'Expedite' }, project: { key: 'FC' }, customfield_10024: [{ name: 'foo' }, { name: 'bar' }] }, changelog: { startAt: 0, maxResults: 2, total: 2, histories: [{ id: '10039', from: 'first_stage', to: 'second_stage', created: '2018-07-08T22:34:47.440-0300' }, { id: '10038', from: 'third_stage', to: 'first_stage', created: '2018-07-06T09:40:43.886-0300' }] } }.with_indifferent_access) }
      let(:jira_account) { Fabricate :jira_account, base_uri: 'http://foo.bar', username: 'foo', password: 'bar', customer_domain: 'xpto' }
      let(:project) { Fabricate :project }
      let!(:jira_config) { Fabricate :project_jira_config, project: project, jira_account_domain: jira_account.customer_domain, jira_project_key: 'FC' }

      let(:team) { Fabricate :team }

      context 'valid responses' do
        context 'and a jira config' do
          context 'and demand' do
            it 'calls the adapter to translation' do
              expect_any_instance_of(Jira::JiraApiService).to(receive(:request_project).with('FC') { jira_project })
              expect_any_instance_of(JIRA::Resource::Project).to(receive(:issues) { [jira_issue] })
              expect_any_instance_of(Jira::JiraApiService).to(receive(:request_issue_details).with('10000') { jira_issue })
              expect(Jira::JiraIssueAdapter.instance).to receive(:process_issue!).with(jira_account, project, jira_issue).once
              Jira::ProcessJiraProjectJob.perform_now(jira_account, 'FC')
            end
          end
        end
      end

      context 'and invalid data' do
        context 'and blank issue response' do
          let(:jira_issue) { client.Issue.build }
          it 'returns doing nothing' do
            expect_any_instance_of(Jira::JiraApiService).to(receive(:request_project).with('FC') { jira_project })
            expect_any_instance_of(JIRA::Resource::Project).to(receive(:issues) { [jira_issue] })
            expect_any_instance_of(Jira::JiraApiService).to(receive(:request_issue_details).never)
            expect(Jira::JiraIssueAdapter.instance).to receive(:process_issue!).never
            Jira::ProcessJiraProjectJob.perform_now(jira_account, 'FC')
          end
        end
      end
    end
  end
end
