# frozen_string_literal: true

RSpec.describe ExportsController, type: :controller do
  context 'unauthenticated' do
    describe 'GET #request_project_information' do
      before { get :request_project_information }
      it { expect(response).to redirect_to new_user_session_path }
    end
    describe 'GET #process_requested_information' do
      before { post :process_requested_information }
      it { expect(response).to redirect_to new_user_session_path }
    end
  end

  context 'authenticated' do
    let(:options) { { username: 'foo', password: 'bar', site: 'https://foo.atlassian.net/', context_path: '/', auth_type: :basic, read_timeout: 120 } }
    let(:client) { JIRA::Client.new(options) }

    let(:jira_account) { Fabricate :jira_account, base_uri: 'https://foo.atlassian.net/', username: 'foo', password: 'bar' }

    let(:user) { Fabricate :user }
    before { sign_in user }

    describe 'POST #process_requested_information' do
      context 'missing fields' do
        it 'returns the CSV to download' do
          returned_issue = client.Issue.build('key' => 'FC-1')
          expect(JIRA::Resource::Issue).to(receive(:find).once { returned_issue })
          expect(JIRA::Resource::Issue).to(receive(:jql).once { [returned_issue] })

          post :process_requested_information, format: :csv

          CSV.parse(response.body, headers: true) do |row|
            expect(row.to_csv).to eq "FC-1,,,,,\n"
          end
        end
      end
      context 'having all fields' do
        it 'returns the CSV to download' do
          returned_issue = client.Issue.build({ key: '10000', fields: { created: '2018-07-02T11:20:18.998-0300', summary: 'foo of bar', issuetype: { name: 'Story' }, customfield_10028: { value: 'Expedite' }, project: { key: 'foo' }, customfield_10024: [{ name: 'foo' }, { name: 'bar' }] }, changelog: { startAt: 0, maxResults: 3, total: 3, histories: [{ id: '10039', created: '2018-07-08T22:34:47.440-0300', items: [{ field: 'status', fromString: 'first_stage', toString: 'second_stage' }] }, { id: '10038', created: '2018-07-06T09:40:43.886-0300', items: [{ field: 'status', fromString: 'third_stage', toString: 'first_stage' }] }, { id: '10038', created: '2018-07-05T09:40:43.886-0300', items: [{ field: 'status', fromString: 'third_stage', toString: 'first_stage' }] }] } }.with_indifferent_access)
          expect(JIRA::Resource::Issue).to(receive(:find).once { returned_issue })
          expect(JIRA::Resource::Issue).to(receive(:jql).once { [returned_issue] })

          post :process_requested_information, format: :csv

          CSV.parse(response.body, headers: true) do |row|
            expect(row.headers).to eq %w[jira_key project_key issue_type class_of_service created_date first_stage second_stage]
            expect(row.to_csv).to eq "10000,foo,Story,,2018-07-02T11:20:18.998-0300,2018-07-05T09:40:43.886-0300,2018-07-08T22:34:47.440-0300\n"
          end
        end
      end
    end
  end
end
