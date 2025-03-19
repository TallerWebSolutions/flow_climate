# frozen_string_literal: true

RSpec.describe Jira::ProcessJiraIssueJob, type: :active_job do
  describe '.perform_later' do
    it 'enqueues after calling perform_later' do
      described_class.perform_later('value1', 'value2', 'value3', 'value4', 'value5', 'value6')

      expect(described_class).to have_been_enqueued.with('value1', 'value2', 'value3', 'value4', 'value5', 'value6').on_queue('critical')
    end
  end

  describe '.perform' do
    let(:options) { { username: 'foo', password: 'bar', site: 'http://foo.bar', context_path: '/', auth_type: :basic } }
    let(:client) { JIRA::Client.new(options) }

    let(:company) { Fabricate :company }
    let(:customer) { Fabricate :customer, company: company }
    let(:product) { Fabricate :product, company: company, customer: customer }
    let(:project) { Fabricate :project, end_date: Time.zone.iso8601('2018-02-16T23:01:46-02:00') }
    let(:team) { Fabricate :team }
    let(:demand) { Fabricate :demand, project: project }

    let(:jira_account) { Fabricate :jira_account, company: company, base_uri: 'http://foo.bar', username: 'foo', api_token: 'bar' }

    context 'when it has a valid response' do
      context 'and it has only one page' do
        let!(:jira_issue) { client.Issue.build({ key: '10000', summary: 'foo of bar', fields: { created: '2018-07-02T11:20:18.998-0300', issuetype: { name: 'Story' }, customfield_10028: { value: 'Expedite' }, project: { key: 'foo' }, customfield_10024: [{ name: 'foo' }, { name: 'bar' }], creator: { displayName: 'creator' } }, changelog: { startAt: 0, maxResults: 2, total: 2, histories: [{ id: '10039', from: 'first_stage', to: 'second_stage', created: '2018-07-08T22:34:47.440-0300' }, { id: '10038', from: 'third_stage', to: 'first_stage', created: '2018-07-06T09:40:43.886-0300' }] } }.with_indifferent_access) }
        let!(:jira_issue_changelog) { instance_double(Net::HTTPSuccess, body: file_fixture('issue_changelog_with_blocks.json').read) }

        it 'calls the adapter to translation' do
          expect(UserNotifierMailer).to receive(:async_activity_finished).once.and_call_original
          allow_any_instance_of(Jira::JiraApiService).to(receive(:request_issue).with('foo') { jira_issue })
          allow_any_instance_of(Jira::JiraApiService).to(receive(:request_issue_changelog).with('foo', 0, 100) { JSON.parse(jira_issue_changelog.body) })

          expect(Jira::JiraIssueAdapter.instance).to(receive(:process_issue).once { demand })
          expect(Jira::JiraIssueAdapter.instance).to(receive(:process_jira_issue_changelog).once)
          described_class.perform_now('foo', jira_account, project, 'foo@bar.com', 'Foo Bar', 'http://foo.com.br')
        end
      end

      context 'and it has two pages' do
        let!(:jira_issue) { client.Issue.build({ key: 'CRE-726', summary: 'foo of bar', fields: { created: '2018-07-02T11:20:18.998-0300', issuetype: { name: 'Story' }, customfield_10028: { value: 'Expedite' }, project: { key: 'foo' }, customfield_10024: [{ name: 'foo' }, { name: 'bar' }], creator: { displayName: 'creator' } }, changelog: { startAt: 0, maxResults: 2, total: 2, histories: [{ id: '10039', from: 'first_stage', to: 'second_stage', created: '2018-07-08T22:34:47.440-0300' }, { id: '10038', from: 'third_stage', to: 'first_stage', created: '2018-07-06T09:40:43.886-0300' }] } }.with_indifferent_access) }
        let!(:jira_issue_changelog_page_one) { instance_double(Net::HTTPSuccess, body: file_fixture('issue_changelog_paginated_page_one.json').read) }
        let!(:jira_issue_changelog_page_two) { instance_double(Net::HTTPSuccess, body: file_fixture('issue_changelog_paginated_page_two.json').read) }

        it 'calls the adapter to translation' do
          expect(UserNotifierMailer).to receive(:async_activity_finished).once.and_call_original

          allow_any_instance_of(Jira::JiraApiService).to(receive(:request_issue).with('foo') { jira_issue })
          allow_any_instance_of(Jira::JiraApiService).to(receive(:request_issue_changelog).with('foo', 0, 100) { JSON.parse(jira_issue_changelog_page_one.body) })
          allow_any_instance_of(Jira::JiraApiService).to(receive(:request_issue_changelog).with('foo', 100, 100) { JSON.parse(jira_issue_changelog_page_two.body) })

          expect(Jira::JiraIssueAdapter.instance).to(receive(:process_issue).once { demand })
          expect(Jira::JiraIssueAdapter.instance).to(receive(:process_jira_issue_changelog).twice)
          described_class.perform_now('foo', jira_account, project, 'foo@bar.com', 'Foo Bar', 'http://foo.com.br')
        end
      end
    end

    context 'with a discarded demand' do
      it 'updates the correct fields' do
        demand = Fabricate :demand, company: company, discarded_at: 2.days.ago

        jira_issue = client.Issue.build
        allow(jira_issue).to receive(:instance_variable_get).with('@expanded').and_return(true)

        allow_any_instance_of(Jira::JiraApiService).to(receive(:request_issue).with(demand.external_id).and_return(jira_issue))
        expect(DemandEffortService.instance).to(receive(:build_efforts_to_demand).with(demand)).once
        expect(UserNotifierMailer).not_to receive(:async_activity_finished)

        described_class.perform_now(demand.external_id, jira_account, project, 'foo@bar.com', 'Foo Bar', 'http://foo.com.br')
      end
    end

    context 'and invalid data' do
      context 'and blank issue response' do
        let(:jira_issue) { client.Issue.build }

        it 'returns doing nothing' do
          allow_any_instance_of(Jira::JiraApiService).to(receive(:request_issue).with('foo') { jira_issue })

          expect(Jira::JiraIssueAdapter.instance).not_to(receive(:process_issue))
          expect(Jira::JiraIssueAdapter.instance).not_to(receive(:process_jira_issue_changelog))
          described_class.perform_now('foo', jira_account, project, 'foo@bar.com', 'Foo Bar', 'http://foo.com.br')
        end
      end
    end
  end
end
