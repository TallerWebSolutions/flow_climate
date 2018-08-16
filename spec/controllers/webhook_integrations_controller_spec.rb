# frozen_string_literal: true

RSpec.describe WebhookIntegrationsController, type: :controller do
  describe 'POST #pipefy_webhook' do
    context 'when the content type is no application/json' do
      before { request.headers['Content-Type'] = 'text/plain' }
      it 'returns bad request' do
        post :pipefy_webhook
        expect(response).to have_http_status :bad_request
      end
    end
    context 'when the content type is application/json' do
      it 'enqueues the job' do
        request.headers['Content-Type'] = 'application/json'
        expect(Pipefy::ProcessPipefyCardJob).to receive(:perform_later).once
        post :pipefy_webhook
        expect(response).to have_http_status :ok
      end
    end
  end
  describe 'POST #jira_webhook' do
    context 'when the content type is not application/json' do
      before { request.headers['Content-Type'] = 'text/plain' }
      it 'returns bad request' do
        post :jira_webhook
        expect(response).to have_http_status :bad_request
      end
    end
    context 'when the content type is application/json' do
      context 'and the project has a valid registration' do
        let!(:jira_account) { Fabricate :jira_account, base_uri: 'http://foo.bar', username: 'foo', password: 'bar', customer_domain: 'bar' }
        let(:project) { Fabricate :project }
        let!(:project_jira_config) { Fabricate :project_jira_config, project: project, jira_account_domain: 'bar', jira_project_key: 'foo' }
        it 'enqueues the job' do
          request.headers['Content-Type'] = 'application/json'
          expect(Jira::ProcessJiraIssueJob).to receive(:perform_later).once
          post :jira_webhook, params: { issue: { key: 'FC-6', fields: { project: { key: 'foo', self: 'http://bar.atlassian.com' }, fixVersions: [{ name: 'foo' }] } }.with_indifferent_access }
          expect(response).to have_http_status :ok
        end
      end
      context 'and the project has an invalid registration without jira config' do
        let!(:jira_account) { Fabricate :jira_account, base_uri: 'http://foo.bar', username: 'foo', password: 'bar' }
        let(:project) { Fabricate :project }
        it 'does not enqueue the job' do
          request.headers['Content-Type'] = 'application/json'
          expect(Jira::ProcessJiraIssueJob).to receive(:perform_later).never
          post :jira_webhook, params: { issue: { key: 'FC-6', fields: { project: { key: 'foo', self: 'http://bar.atlassian.com' }, fixVersions: [{ name: 'foo' }] } }.with_indifferent_access }
          expect(response).to have_http_status :ok
        end
      end
      context 'and the project has an invalid registration without jira account' do
        let(:project) { Fabricate :project }
        let!(:project_jira_config) { Fabricate :project_jira_config, project: project, jira_account_domain: 'bar', jira_project_key: 'foo' }
        it 'does not enqueue the job' do
          request.headers['Content-Type'] = 'application/json'
          expect(Jira::ProcessJiraIssueJob).to receive(:perform_later).never
          post :jira_webhook, params: { issue: { key: 'FC-6', fields: { project: { key: 'foo', self: 'http://bar.atlassian.com' }, fixVersions: [{ name: 'foo' }] } }.with_indifferent_access }
          expect(response).to have_http_status :ok
        end
      end
    end
  end

  describe 'POST #jira_delete_card_webhook' do
    context 'when the content type is not application/json' do
      before { request.headers['Content-Type'] = 'text/plain' }
      it 'returns bad request' do
        post :jira_delete_card_webhook
        expect(response).to have_http_status :bad_request
      end
    end
    context 'when the content type is application/json' do
      context 'and the project has a valid registration' do
        let!(:jira_account) { Fabricate :jira_account, base_uri: 'http://foo.bar', username: 'foo', password: 'bar', customer_domain: 'bar' }
        let(:project) { Fabricate :project }
        let!(:project_jira_config) { Fabricate :project_jira_config, project: project, jira_account_domain: 'bar', jira_project_key: 'foo' }

        context 'when the demand exists' do
          let!(:demand) { Fabricate :demand, project: project, demand_id: 'FC-6' }
          it 'deletes the demand' do
            request.headers['Content-Type'] = 'application/json'
            expect(DemandsRepository.instance).to receive(:full_demand_destroy!).with(demand).once
            post :jira_delete_card_webhook, params: { issue: { key: 'FC-6', fields: { project: { key: 'foo', self: 'http://bar.atlassian.com' }, fixVersions: [{ name: 'foo' }] } }.with_indifferent_access }
            expect(response).to have_http_status :ok
          end
        end
        context 'when the demand does not exist' do
          it 'does nothing' do
            request.headers['Content-Type'] = 'application/json'
            expect(DemandsRepository.instance).to receive(:full_demand_destroy!).with(nil).once
            post :jira_delete_card_webhook, params: { issue: { key: 'FC-6', fields: { project: { key: 'foo', self: 'http://bar.atlassian.com' }, fixVersions: [{ name: 'foo' }] } }.with_indifferent_access }
            expect(response).to have_http_status :ok
          end
        end
      end
      context 'and the project has an invalid registration without jira config' do
        let!(:jira_account) { Fabricate :jira_account, base_uri: 'http://foo.bar', username: 'foo', password: 'bar' }
        let(:project) { Fabricate :project }
        it 'does nothing' do
          request.headers['Content-Type'] = 'application/json'
          expect(DemandsRepository.instance).to receive(:full_demand_destroy!).never
          post :jira_delete_card_webhook, params: { issue: { key: 'FC-6', fields: { project: { key: 'foo', self: 'http://bar.atlassian.com' }, fixVersions: [{ name: 'foo' }] } }.with_indifferent_access }
          expect(response).to have_http_status :ok
        end
      end
    end
  end
end
