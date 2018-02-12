# frozen_string_literal: true

class WebhookIntegrationsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def pipefy_webhook
    return head :bad_request if request.headers['Content-Type'] != 'application/json'
    data = JSON.parse(request.body.read)
    ProcessPipefyCardJob.perform_later(data)
    head :ok
  end
end
