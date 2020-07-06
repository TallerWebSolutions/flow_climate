# frozen_string_literal: true

RSpec.describe WebhookIntegrationsController, type: :controller do
  let(:options) { { username: 'foo', password: 'bar', site: 'http://foo.bar', context_path: '/', auth_type: :basic } }
  let(:client) { JIRA::Client.new(options) }

  describe 'POST #jira_webhook' do
    let(:company) { Fabricate :company }
    let(:customer) { Fabricate :customer, company: company }
    let(:product) { Fabricate :product, customer: customer }

    context 'when the content type is not application/json' do
      before { request.headers['Content-Type'] = 'text/plain' }

      it 'returns bad request' do
        post :jira_webhook
        expect(response).to have_http_status :bad_request
      end
    end

    context 'when the content type is application/json' do
      context 'and the has a valid project' do
        let!(:jira_account) { Fabricate :jira_account, company: company, base_uri: 'http://foo.bar', username: 'foo', api_token: 'bar', customer_domain: 'bar' }
        let(:project) { Fabricate :project, company: company, customers: [customer], products: [product] }
        let!(:jira_product_config) { Fabricate :jira_product_config, product: product, jira_product_key: 'FC' }

        let!(:jira_project_config) { Fabricate :jira_project_config, project: project, jira_product_config: jira_product_config, fix_version_name: 'foo' }

        context 'with fixVersion' do
          let!(:jira_issue) { client.Issue.build({ key: '10000', fields: { created: '2018-07-02T11:20:18.998-0300', summary: 'foo of bar', issuetype: { name: 'Story' }, customfield_10028: { value: 'Expedite' }, project: { key: 'FC', self: 'http://bar.atlassian.com' }, customfield_10024: [{ name: 'foo' }, { name: 'bar' }], comment: { comments: [{ created: Time.zone.local(2019, 5, 27, 10, 0, 0).iso8601, body: 'comment example' }] }, fixVersions: [{ name: 'foo' }] }, changelog: { startAt: 0, maxResults: 2, total: 2, histories: [{ id: '10039', from: 'first_stage', to: 'second_stage', created: '2018-07-08T22:34:47.440-0300' }, { id: '10038', from: 'third_stage', to: 'first_stage', created: '2018-07-06T09:40:43.886-0300' }] } }.with_indifferent_access) }

          it 'enqueues the job' do
            request.headers['Content-Type'] = 'application/json'
            expect(Jira::ProcessJiraIssueJob).to receive(:perform_later).once
            post :jira_webhook, params: { issue: jira_issue.attrs }
            expect(response).to have_http_status :ok
          end
        end

        context 'with label' do
          let!(:jira_issue) { client.Issue.build({ key: '10000', fields: { created: '2018-07-02T11:20:18.998-0300', summary: 'foo of bar', issuetype: { name: 'Story' }, customfield_10028: { value: 'Expedite' }, project: { key: 'FC', self: 'http://bar.atlassian.com' }, customfield_10024: [{ name: 'foo' }, { name: 'bar' }], comment: { comments: [{ created: Time.zone.local(2019, 5, 27, 10, 0, 0).iso8601, body: 'comment example' }] }, labels: ['foo'] }, changelog: { startAt: 0, maxResults: 2, total: 2, histories: [{ id: '10039', from: 'first_stage', to: 'second_stage', created: '2018-07-08T22:34:47.440-0300' }, { id: '10038', from: 'third_stage', to: 'first_stage', created: '2018-07-06T09:40:43.886-0300' }] } }.with_indifferent_access) }

          it 'enqueues the job' do
            request.headers['Content-Type'] = 'application/json'
            expect(Jira::ProcessJiraIssueJob).to receive(:perform_later).once
            post :jira_webhook, params: { issue: jira_issue.attrs }
            expect(response).to have_http_status :ok
          end
        end
      end

      context 'and the project has an invalid registration without jira config' do
        let!(:jira_account) { Fabricate :jira_account, base_uri: 'http://foo.bar', username: 'foo', api_token: 'bar' }
        let(:project) { Fabricate :project }

        let!(:jira_issue) { client.Issue.build({ key: '10000', fields: { created: '2018-07-02T11:20:18.998-0300', summary: 'foo of bar', issuetype: { name: 'Story' }, customfield_10028: { value: 'Expedite' }, project: { key: 'FC', self: 'http://bar.atlassian.com' }, customfield_10024: [{ name: 'foo' }, { name: 'bar' }], comment: { comments: [{ created: Time.zone.local(2019, 5, 27, 10, 0, 0).iso8601, body: 'comment example' }] }, fixVersions: [{ name: 'foo' }] }, changelog: { startAt: 0, maxResults: 2, total: 2, histories: [{ id: '10039', from: 'first_stage', to: 'second_stage', created: '2018-07-08T22:34:47.440-0300' }, { id: '10038', from: 'third_stage', to: 'first_stage', created: '2018-07-06T09:40:43.886-0300' }] } }.with_indifferent_access) }

        it 'does not enqueue the job' do
          request.headers['Content-Type'] = 'application/json'
          expect(Jira::ProcessJiraIssueJob).not_to receive(:perform_later)
          post :jira_webhook, params: { issue: jira_issue.attrs }
          expect(response).to have_http_status :ok
        end
      end

      context 'and the project has an invalid data without jira account' do
        let(:project) { Fabricate :project }
        let!(:jira_project_config) { Fabricate :jira_project_config, project: project, fix_version_name: 'foo' }

        let!(:jira_issue) { client.Issue.build({ key: '10000', fields: { created: '2018-07-02T11:20:18.998-0300', summary: 'foo of bar', issuetype: { name: 'Story' }, customfield_10028: { value: 'Expedite' }, project: { key: 'FC', self: 'http://bar.atlassian.com' }, customfield_10024: [{ name: 'foo' }, { name: 'bar' }], comment: { comments: [{ created: Time.zone.local(2019, 5, 27, 10, 0, 0).iso8601, body: 'comment example' }] }, fixVersions: [{ name: 'foo' }] }, changelog: { startAt: 0, maxResults: 2, total: 2, histories: [{ id: '10039', from: 'first_stage', to: 'second_stage', created: '2018-07-08T22:34:47.440-0300' }, { id: '10038', from: 'third_stage', to: 'first_stage', created: '2018-07-06T09:40:43.886-0300' }] } }.with_indifferent_access) }

        it 'does not enqueue the job' do
          request.headers['Content-Type'] = 'application/json'
          expect(Jira::ProcessJiraIssueJob).not_to receive(:perform_later)
          post :jira_webhook, params: { issue: jira_issue.attrs }
          expect(response).to have_http_status :ok
        end
      end
    end
  end

  describe 'POST #jira_delete_card_webhook' do
    let(:company) { Fabricate :company }
    let(:customer) { Fabricate :customer, company: company }
    let(:product) { Fabricate :product, customer: customer }

    let!(:jira_issue) { client.Issue.build({ key: '10000', fields: { created: '2018-07-02T11:20:18.998-0300', summary: 'foo of bar', issuetype: { name: 'Story' }, customfield_10028: { value: 'Expedite' }, project: { key: 'FC', self: 'http://bar.atlassian.com' }, customfield_10024: [{ name: 'foo' }, { name: 'bar' }], comment: { comments: [{ created: Time.zone.local(2019, 5, 27, 10, 0, 0).iso8601, body: 'comment example' }] }, fixVersions: [{ name: 'foo' }] }, changelog: { startAt: 0, maxResults: 2, total: 2, histories: [{ id: '10039', from: 'first_stage', to: 'second_stage', created: '2018-07-08T22:34:47.440-0300' }, { id: '10038', from: 'third_stage', to: 'first_stage', created: '2018-07-06T09:40:43.886-0300' }] } }.with_indifferent_access) }

    context 'when the content type is not application/json' do
      before { request.headers['Content-Type'] = 'text/plain' }

      it 'returns bad request' do
        post :jira_delete_card_webhook
        expect(response).to have_http_status :bad_request
      end
    end

    context 'when the content type is application/json' do
      context 'and the project has a valid registration' do
        let!(:jira_account) { Fabricate :jira_account, company: company, base_uri: 'http://foo.bar', username: 'foo', api_token: 'bar', customer_domain: 'bar' }
        let(:project) { Fabricate :project, company: company, customers: [customer], products: [product] }
        let!(:jira_product_config) { Fabricate :jira_product_config, product: product, jira_product_key: 'FC' }

        let!(:jira_project_config) { Fabricate :jira_project_config, project: project, jira_product_config: jira_product_config, fix_version_name: 'foo' }

        context 'when the demand exists' do
          let!(:demand) { Fabricate :demand, project: project, external_id: '10000' }

          it 'deletes the demand' do
            request.headers['Content-Type'] = 'application/json'
            post :jira_delete_card_webhook, params: { issue: jira_issue.attrs }
            expect(response).to have_http_status :ok
            expect(Demand.kept.count).to eq 0
          end
        end

        context 'when the demand does not exist' do
          it 'does nothing' do
            request.headers['Content-Type'] = 'application/json'
            post :jira_delete_card_webhook, params: { issue: jira_issue.attrs }
            expect(response).to have_http_status :ok
          end
        end
      end

      context 'and the project has an invalid registration without jira config' do
        let!(:jira_account) { Fabricate :jira_account, base_uri: 'http://foo.bar', username: 'foo', api_token: 'bar' }
        let(:project) { Fabricate :project }

        it 'does nothing' do
          request.headers['Content-Type'] = 'application/json'
          post :jira_delete_card_webhook, params: { issue: jira_issue.attrs }
          expect(response).to have_http_status :ok
        end
      end
    end
  end
end
