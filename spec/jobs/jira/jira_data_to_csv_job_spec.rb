# frozen_string_literal: true

RSpec.describe Jira::JiraDataToCsvJob, type: :active_job do
  describe '.perform_later' do
    it 'enqueues after calling perform_later' do
      described_class.perform_later(bla: 'foo')
      expect(described_class).to have_been_enqueued.on_queue('default')
    end
  end

  describe '.perform' do
    let(:user) { Fabricate :user, admin: true }
    let(:plan) { Fabricate :plan }
    let!(:user_plan) { Fabricate :user_plan, plan: plan, user: user, active: true, paid: true }

    let(:options) { { username: 'foo', password: 'bar', site: 'https://foo.atlassian.net/', context_path: '/', auth_type: :basic, read_timeout: 120 } }
    let(:client) { JIRA::Client.new(options) }

    let(:jira_account) { Fabricate :jira_account, base_uri: 'https://foo.atlassian.net/', username: 'foo', api_token: 'bar' }

    let(:jira_api_service) { Jira::JiraApiService.new('foo', 'bar', 'https://foo.atlassian.net/') }

    context 'correct informations' do
      context 'querying by fix version and project key' do
        it 'computes the CSV, saves it and send an email with the content' do
          returned_issue = client.Issue.build({ key: '10000', fields: { created: '2018-07-02T11:20:18.998-0300', summary: 'foo of bar', issuetype: { name: 'Story' }, customfield_10028: { value: 'Expedite' }, project: { key: 'foo' }, customfield_10024: [{ name: 'foo' }, { name: 'bar' }] }, changelog: { startAt: 0, maxResults: 3, total: 3, histories: [{ id: '10039', created: '2018-07-08T22:34:47.440-0300', items: [{ field: 'status', fromString: 'first_stage', toString: 'second_stage' }] }, { id: '10038', created: '2018-07-06T09:40:43.886-0300', items: [{ field: 'status', fromString: 'third_stage', toString: 'first_stage' }] }, { id: '10038', created: '2018-07-05T09:40:43.886-0300', items: [{ field: 'status', fromString: 'third_stage', toString: 'first_stage' }] }] } }.with_indifferent_access)
          expect(JIRA::Resource::Issue).to(receive(:find).once { returned_issue })
          expect(JIRA::Resource::Issue).to(receive(:jql).once { [returned_issue] })

          expect(UserNotifierMailer).to receive(:jira_requested_csv).once.and_call_original

          described_class.perform_now('foo', 'bar', 'https://foo.atlassian.net/', 'NSC', 'NSCT', 'Fase 1', 'class_of_service_field', user.id)

          expect(DemandDataProcessment.count).to eq 1
          expect(DemandDataProcessment.first.user).to eq user
          expect(DemandDataProcessment.first.project_key).to eq 'foo'
          expect(DemandDataProcessment.first.user_plan).to eq user_plan
          expect(DemandDataProcessment.first.downloaded_content).to eq "jira_key,project_key,issue_type,class_of_service,created_date,first_stage,second_stage\n10000,foo,Story,,2018-07-02T11:20:18.998-0300,2018-07-05T09:40:43.886-0300,2018-07-08T22:34:47.440-0300\n"
        end
      end

      context 'querying by project key' do
        it 'computes the CSV, saves it and send an email with the content' do
          returned_project = client.Project.build({ fields: { key: 'FC', name: 'flow climate' } }.with_indifferent_access)
          returned_issue = client.Issue.build({ key: '10000', fields: { created: '2018-07-02T11:20:18.998-0300', summary: 'foo of bar', issuetype: { name: 'Story' }, customfield_10028: { value: 'Expedite' }, project: { key: 'foo' }, customfield_10024: [{ name: 'foo' }, { name: 'bar' }] }, changelog: { startAt: 0, maxResults: 3, total: 3, histories: [{ id: '10039', created: '2018-07-08T22:34:47.440-0300', items: [{ field: 'status', fromString: 'first_stage', toString: 'second_stage' }] }, { id: '10038', created: '2018-07-06T09:40:43.886-0300', items: [{ field: 'status', fromString: 'third_stage', toString: 'first_stage' }] }, { id: '10038', created: '2018-07-05T09:40:43.886-0300', items: [{ field: 'status', fromString: 'third_stage', toString: 'first_stage' }] }] } }.with_indifferent_access)
          expect(JIRA::Resource::Project).to(receive(:find).once { returned_project })
          expect_any_instance_of(JIRA::Resource::Project).to(receive(:issues).once { [returned_issue] })
          expect(JIRA::Resource::Issue).to(receive(:find).once { returned_issue })

          expect(JIRA::Resource::Issue).not_to(receive(:jql))

          described_class.perform_now('foo', 'bar', 'https://foo.atlassian.net/', 'NSC', 'FC', nil, 'class_of_service_field', user.id)

          expect(DemandDataProcessment.count).to eq 1
          expect(DemandDataProcessment.first.user).to eq user
          expect(DemandDataProcessment.first.project_key).to eq 'foo'
          expect(DemandDataProcessment.first.user_plan).to eq user_plan
          expect(DemandDataProcessment.first.downloaded_content).to eq "jira_key,project_key,issue_type,class_of_service,created_date,first_stage,second_stage\n10000,foo,Story,,2018-07-02T11:20:18.998-0300,2018-07-05T09:40:43.886-0300,2018-07-08T22:34:47.440-0300\n"
        end
      end
    end
  end
end
