# frozen_string_literal: true

RSpec.describe Jira::JiraApiService, type: :service do
  let(:options) { { username: 'foo', password: 'bar', site: 'https://foo.atlassian.net/', context_path: '/', auth_type: :basic, read_timeout: 120 } }
  let(:client) { JIRA::Client.new(options) }

  let(:jira_account) { Fabricate :jira_account, base_uri: 'https://foo.atlassian.net/', username: 'foo', password: 'bar' }

  describe '#request_issue_details' do
    context 'when the issue exists' do
      it 'returns the issue details' do
        returned_issue = client.Issue.build(summary: 'foo of bar')
        expect(JIRA::Resource::Issue).to(receive(:find).once { returned_issue })

        issue_details = Jira::JiraApiService.new(jira_account.username, jira_account.password, jira_account.base_uri).request_issue_details('FC-3')

        expect(issue_details.attrs[:summary]).to eq 'foo of bar'
      end
    end

    context 'when the issue does not exist' do
      it 'returns an empty Issue' do
        response = Net::HTTPResponse.new(1.0, 404, 'not found')
        expect(JIRA::Resource::Issue).to(receive(:find).once.and_raise(JIRA::HTTPError.new(response)))

        issue_details = Jira::JiraApiService.new(jira_account.username, jira_account.password, jira_account.base_uri).request_issue_details('FC-1')

        expect(issue_details.attrs[:summary]).to be_nil
        expect(issue_details.id).to be_nil
      end
    end
  end

  describe '#request_issues_by_fix_version' do
    context 'when the project exists' do
      it 'returns the project' do
        returned_issue = client.Issue.build(summary: 'foo of bar')
        expect(JIRA::Resource::Issue).to(receive(:jql).once { [returned_issue] })

        Jira::JiraApiService.new(jira_account.username, jira_account.password, jira_account.base_uri).request_issues_by_fix_version('fix version name', 'FC')
      end
    end

    context 'when the issue does not exist' do
      it 'returns an empty Issue' do
        response = Net::HTTPResponse.new(1.0, 404, 'not found')
        expect(JIRA::Resource::Issue).to(receive(:jql).twice.and_raise(JIRA::HTTPError.new(response)))

        issues_returned = Jira::JiraApiService.new(jira_account.username, jira_account.password, jira_account.base_uri).request_issues_by_fix_version('fix version name', 'EX')

        expect(issues_returned).to be_empty
      end
    end
  end

  describe '#request_project' do
    context 'when the project exists' do
      it 'returns the project' do
        returned_project = client.Project.build(key: 'bar', name: 'bar', id: '10102')
        expect(JIRA::Resource::Project).to(receive(:find).once { [returned_project] })

        Jira::JiraApiService.new(jira_account.username, jira_account.password, jira_account.base_uri).request_project('10102')
      end
    end

    context 'when the project does not exist' do
      it 'returns an empty Issue' do
        response = Net::HTTPResponse.new(1.0, 404, 'not found')
        expect(JIRA::Resource::Project).to(receive(:find).once.and_raise(JIRA::HTTPError.new(response)))

        project_returned = Jira::JiraApiService.new(jira_account.username, jira_account.password, jira_account.base_uri).request_project('EX')

        expect(project_returned.attrs).to be_empty
      end
    end
  end

  describe '#request_status' do
    context 'when the status exists' do
      it 'returns the project' do
        returned_status = client.Status.build(id: 'bar', name: 'bar')
        expect(JIRA::Resource::Status).to(receive(:all).once { [returned_status] })

        Jira::JiraApiService.new(jira_account.username, jira_account.password, jira_account.base_uri).request_status
      end
    end

    context 'when the status does not exist' do
      it 'returns an empty Issue' do
        response = Net::HTTPResponse.new(1.0, 404, 'not found')
        expect(JIRA::Resource::Status).to(receive(:all).once.and_raise(JIRA::HTTPError.new(response)))

        returned_status = Jira::JiraApiService.new(jira_account.username, jira_account.password, jira_account.base_uri).request_status

        expect(returned_status).to eq []
      end
    end
  end
end
