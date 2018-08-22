# frozen_string_literal: true

RSpec.describe Jira::JiraApiService, type: :service do
  let(:options) { { username: 'foo', password: 'bar', site: 'https://foo.atlassian.net/', context_path: '/', auth_type: :basic, read_timeout: 120 } }
  let(:client) { JIRA::Client.new(options) }

  let(:jira_account) { Fabricate :jira_account, base_uri: 'https://foo.atlassian.net/', username: 'foo', password: 'bar' }

  describe '.request_issue_details' do
    context 'when the issue exists' do
      it 'returns the issue details' do
        returned_issue = client.Issue.build(summary: 'foo of bar')
        expect(JIRA::Resource::Issue).to(receive(:find).once { returned_issue })

        # WebMock.disable!

        issue_details = Jira::JiraApiService.new(jira_account).request_issue_details('FC-3')

        expect(issue_details.attrs[:summary]).to eq 'foo of bar'
      end
    end

    context 'when the issue does not exist' do
      it 'returns an empty Issue' do
        response = Net::HTTPResponse.new(1.0, 404, 'not found')
        expect(JIRA::Resource::Issue).to(receive(:find).once.and_raise(JIRA::HTTPError.new(response)))

        issue_details = Jira::JiraApiService.new(jira_account).request_issue_details('FC-1')

        expect(issue_details.attrs[:summary]).to be_nil
        expect(issue_details.id).to be_nil
      end
    end
  end

  describe '.request_project' do
    context 'when the project exists' do
      it 'returns the project' do
        returned_project = client.Project.build(key: 'EX', name: 'Example', projectTypeKey: 'business', lead: 'username')
        expect(JIRA::Resource::Project).to(receive(:find).once { returned_project })

        # WebMock.disable!

        project = Jira::JiraApiService.new(jira_account).request_project('FC')

        expect(project.attrs[:name]).to eq 'Example'
      end
    end

    context 'when the issue does not exist' do
      it 'returns an empty Issue' do
        response = Net::HTTPResponse.new(1.0, 404, 'not found')
        expect(JIRA::Resource::Project).to(receive(:find).once.and_raise(JIRA::HTTPError.new(response)))

        project = Jira::JiraApiService.new(jira_account).request_project('EX')

        expect(project.attrs[:name]).to be_nil
      end
    end
  end
end
