# frozen_string_literal: true

RSpec.describe Jira::ProcessJiraIssueJob, type: :active_job do
  describe '.perform_later' do
    it 'enqueues after calling perform_later' do
      Jira::ProcessJiraIssueJob.perform_later(bla: 'foo')
      expect(Jira::ProcessJiraIssueJob).to have_been_enqueued.on_queue('default')
    end
  end

  describe '.perform' do
    context 'having params' do
      let(:options) { { username: 'foo', password: 'bar', site: 'http://foo.bar', context_path: '/', auth_type: :basic, read_timeout: 120 } }
      let(:client) { JIRA::Client.new(options) }

      let(:project) { Fabricate :project, end_date: Time.zone.iso8601('2018-02-16T23:01:46-02:00') }
      let!(:jira_issue) { client.Issue.build({ key: '10000', summary: 'foo of bar', fields: { created: '2018-07-02T11:20:18.998-0300', issuetype: { name: 'Story' }, customfield_10028: { value: 'Expedite' }, project: { key: 'foo' }, customfield_10024: [{ name: 'foo' }, { name: 'bar' }] }, changelog: { startAt: 0, maxResults: 2, total: 2, histories: [{ id: '10039', from: 'first_stage', to: 'second_stage', created: '2018-07-08T22:34:47.440-0300' }, { id: '10038', from: 'third_stage', to: 'first_stage', created: '2018-07-06T09:40:43.886-0300' }] } }.with_indifferent_access) }
      let(:jira_account) { Fabricate :jira_account, base_uri: 'http://foo.bar', username: 'foo', password: 'bar' }
      let(:team) { Fabricate :team }
      let(:demand) { Fabricate :demand, project: project }

      context 'valid responses' do
        context 'and a jira config' do
          context 'and demand' do
            it 'calls the adapter to translation' do
              expect(UserNotifierMailer).to receive(:sync_finished).once.and_call_original
              expect_any_instance_of(Jira::JiraApiService).to(receive(:request_issue_details).with('foo') { jira_issue })
              expect(Jira::JiraIssueAdapter.instance).to(receive(:process_issue!).with(jira_account, project, jira_issue).once { demand })
              Jira::ProcessJiraIssueJob.perform_now(jira_account, project, 'foo', 'foo@bar.com', 'Foo Bar', 'http://foo.com.br')
            end
          end
        end
      end

      context 'and invalid data' do
        context 'and blank issue response' do
          let(:jira_issue) { client.Issue.build }
          it 'returns doing nothing' do
            expect_any_instance_of(Jira::JiraApiService).to(receive(:request_issue_details).with('foo') { jira_issue })
            expect(Jira::JiraIssueAdapter.instance).to receive(:process_issue!).never
            Jira::ProcessJiraIssueJob.perform_now(jira_account, project, 'foo', 'foo@bar.com', 'Foo Bar', 'http://foo.com.br')
          end
        end
      end
    end
  end
end
