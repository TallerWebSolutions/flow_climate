# frozen_string_literal: true

RSpec.describe Jira::JiraApiService, type: :service do
  let(:options) { { username: 'foo', password: 'bar', site: 'http://foo.bar', context_path: '/', auth_type: :basic, read_timeout: 120 } }
  let(:client) { JIRA::Client.new(options) }

  let(:jira_account) { Fabricate :jira_account, base_uri: 'http://foo.bar', username: 'foo', password: 'bar' }
  # let(:jira_account) { Fabricate :jira_account, base_uri: 'https://tallerflow.atlassian.net/', username: 'celso@taller.net.br', password: 'roots1981' }

  describe '.request_issue_details' do
    context 'when the issue exists' do
      it 'returns the issue details' do
        returned_issue = client.Issue.build(summary: 'foo of bar')
        expect(JIRA::Resource::Issue).to(receive(:find).once { returned_issue })

        # WebMock.disable!

        card_details = Jira::JiraApiService.new(jira_account).request_issue_details('FC-3')

        expect(card_details.attrs[:summary]).to eq 'foo of bar'
      end
    end

    context 'when the issue does not exist' do
      it 'returns an empty Issue' do
        response = Net::HTTPResponse.new(1.0, 404, 'not found')
        expect(JIRA::Resource::Issue).to(receive(:find).once.and_raise(JIRA::HTTPError.new(response)))

        card_details = Jira::JiraApiService.new(jira_account).request_issue_details('FC-1')

        expect(card_details.attrs[:summary]).to be_nil
        expect(card_details.id).to be_nil
      end
    end
  end
end
