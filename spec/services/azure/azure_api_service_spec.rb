# frozen_string_literal: true

RSpec.describe Azure::AzureApiService, type: :service do
  let(:azure_account) { Fabricate :azure_account, azure_organization: 'bla', username: 'foo', password: 'bar' }

  describe 'request_projects' do
    context 'when success' do
      it 'returns the azure response with the projects list' do
        expect(HTTParty).to(receive(:get).with("#{Figaro.env.azure_base_uri}/#{azure_account.azure_organization}/_apis/projects?api-version=2.0",
                                               basic_auth: { username: azure_account.username, password: azure_account.password })).once
        described_class.new(azure_account).projects
      end
    end

    context 'when failure' do
      it 'returns an empty hash and logs the error' do
        allow(HTTParty).to(receive(:get)).and_raise(Errno::ECONNREFUSED)
        expect(Rails.logger).to(receive(:error)).once

        expect(described_class.new(azure_account).projects).to eq({})
      end
    end
  end
end
