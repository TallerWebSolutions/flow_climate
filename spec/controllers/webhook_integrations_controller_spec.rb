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
end
