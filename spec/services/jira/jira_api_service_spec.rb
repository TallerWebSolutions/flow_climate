# frozen_string_literal: true

RSpec.describe Jira::JiraApiService, type: :service do
  let(:options) { { username: 'foo', password: 'bar', site: 'https://foo.atlassian.net/', context_path: '/', auth_type: :basic } }
  let(:client) { JIRA::Client.new(options) }

  let(:jira_account) { Fabricate :jira_account, base_uri: 'https://foo.atlassian.net/', username: 'foo', api_token: 'bar' }

  describe 'request_issue' do
    context 'when success' do
      it 'returns the issue details' do
        returned_issue = client.Issue.build(summary: 'foo of bar')
        expect(JIRA::Resource::Issue).to(receive(:find).once { returned_issue })

        issue_details = described_class.new(jira_account.username, jira_account.api_token, jira_account.base_uri).request_issue('FC-3')

        expect(issue_details.attrs[:summary]).to eq 'foo of bar'
      end
    end

    context 'when failure' do
      it 'returns an empty issue' do
        response = Net::HTTPResponse.new(1.0, 404, 'not found')
        allow(JIRA::Resource::Issue).to(receive(:find).and_raise(JIRA::HTTPError.new(response)))

        issue_details = described_class.new(jira_account.username, jira_account.api_token, jira_account.base_uri).request_issue('FC-3')

        expect(issue_details).to be_an_instance_of JIRA::Resource::Issue
      end

      context 'when unauthorized' do
        it 'logs the error and returns an empty issue' do
          response = Net::HTTPResponse.new(1.0, 401, 'Unauthorized')
          unauthorized_error = JIRA::HTTPError.new(response)
          allow(unauthorized_error).to receive(:message).and_return('Unauthorized')
          allow(JIRA::Resource::Issue).to(receive(:find).and_raise(unauthorized_error))

          expect(Rails.logger).to receive(:error).with(/JIRA AUTH ERROR: Credenciais inválidas ou token expirado para issue FC-3/)

          issue_details = described_class.new(jira_account.username, jira_account.api_token, jira_account.base_uri).request_issue('FC-3')

          expect(issue_details).to be_an_instance_of JIRA::Resource::Issue
        end
      end

      context 'when other HTTP error' do
        it 'logs the general error and returns an empty issue' do
          response = Net::HTTPResponse.new(1.0, 500, 'Internal Server Error')
          http_error = JIRA::HTTPError.new(response)
          allow(http_error).to receive(:message).and_return('Internal Server Error')
          allow(JIRA::Resource::Issue).to(receive(:find).and_raise(http_error))

          expect(Rails.logger).to receive(:error).with(/JIRA HTTP ERROR: Internal Server Error for issue FC-3/)

          issue_details = described_class.new(jira_account.username, jira_account.api_token, jira_account.base_uri).request_issue('FC-3')

          expect(issue_details).to be_an_instance_of JIRA::Resource::Issue
        end
      end
    end
  end

  describe '#request_issue_changelog' do
    context 'when the issue exists' do
      it 'returns the issue details' do
        jira_issue_changelog = instance_double(Net::HTTPSuccess, body: file_fixture('issue_changelog_with_blocks.json').read)
        expect_any_instance_of(JIRA::Client).to(receive(:get).once.and_return(jira_issue_changelog))

        described_class.new(jira_account.username, jira_account.api_token, jira_account.base_uri).request_issue_changelog('EBANX-2')
      end
    end

    context 'when the issue does not exist' do
      it 'returns an empty Issue' do
        response = Net::HTTPResponse.new(1.0, 404, 'not found')
        expect_any_instance_of(JIRA::Client).to(receive(:get).once.and_raise(JIRA::HTTPError.new(response)))

        issue_details = described_class.new(jira_account.username, jira_account.api_token, jira_account.base_uri).request_issue_changelog('EBANX-2')

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

        described_class.new(jira_account.username, jira_account.api_token, jira_account.base_uri).request_issues_by_fix_version('fix version name', 'FC')
      end
    end

    context 'when the issue does not exist' do
      context 'returning not found' do
        it 'returns an empty Issue' do
          response = Net::HTTPResponse.new(1.0, 404, 'not found')
          expect(JIRA::Resource::Issue).to(receive(:jql).twice.and_raise(JIRA::HTTPError.new(response)))

          issues_returned = described_class.new(jira_account.username, jira_account.api_token, jira_account.base_uri).request_issues_by_fix_version('fix version name', 'EX')

          expect(issues_returned).to be_empty
        end
      end

      context 'returning empty array' do
        it 'returns an empty Issue' do
          expect(JIRA::Resource::Issue).to(receive(:jql).twice.and_return([]))

          issues_returned = described_class.new(jira_account.username, jira_account.api_token, jira_account.base_uri).request_issues_by_fix_version('fix version name', 'EX')

          expect(issues_returned).to be_empty
        end
      end
    end
  end

  describe '#request_project' do
    context 'when the project exists' do
      it 'returns the project' do
        returned_project = client.Project.build(key: 'bar', name: 'bar', id: '10102')
        expect(JIRA::Resource::Project).to(receive(:find).once { [returned_project] })

        described_class.new(jira_account.username, jira_account.api_token, jira_account.base_uri).request_project('10102')
      end
    end

    context 'when the project does not exist' do
      it 'returns an empty Issue' do
        response = Net::HTTPResponse.new(1.0, 404, 'not found')
        expect(JIRA::Resource::Project).to(receive(:find).once.and_raise(JIRA::HTTPError.new(response)))

        project_returned = described_class.new(jira_account.username, jira_account.api_token, jira_account.base_uri).request_project('EX')

        expect(project_returned.attrs).to be_empty
      end
    end
  end

  describe '#request_status' do
    context 'when the status exists' do
      it 'returns the project' do
        returned_status = client.Status.build(id: 'bar', name: 'bar')
        expect(JIRA::Resource::Status).to(receive(:all).once { [returned_status] })

        described_class.new(jira_account.username, jira_account.api_token, jira_account.base_uri).request_status
      end
    end

    context 'when the status does not exist' do
      it 'returns an empty Issue' do
        response = Net::HTTPResponse.new(1.0, 404, 'not found')
        expect(JIRA::Resource::Status).to(receive(:all).once.and_raise(JIRA::HTTPError.new(response)))

        returned_status = described_class.new(jira_account.username, jira_account.api_token, jira_account.base_uri).request_status

        expect(returned_status).to eq []
      end
    end
  end
end
