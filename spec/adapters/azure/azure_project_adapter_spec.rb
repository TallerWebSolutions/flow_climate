# frozen_string_literal: true

RSpec.describe Azure::AzureProjectAdapter do
  describe '#projects' do
    let(:company) { Fabricate :company }
    let(:azure_account) { Fabricate :azure_account, company: company }

    context 'when success' do
      context 'with registered products' do
        it 'returns an array with the products' do
          customer = Fabricate :customer, company: company
          product = Fabricate :product, company: company
          Fabricate :azure_product_config, customer: customer, product: product, azure_account: azure_account, azure_product_name: 'FlowClimate', azure_product_id: '19dd7898-d318-4896-8797-afaf2320dcd3'
          mocked_azure_return = file_fixture('azure_projects_list.json').read

          allow(HTTParty).to(receive(:get)).once { mocked_azure_return }

          expect(described_class.instance.projects(azure_account)).to eq [product]
        end
      end

      context 'without registered products' do
        it 'creates the product and the azure config for it' do
          mocked_azure_return = file_fixture('azure_projects_list.json').read
          allow(HTTParty).to(receive(:get)).once { mocked_azure_return }
          expect(described_class.instance.projects(azure_account)).to eq [Product.all.first]
        end
      end
    end

    context 'when failed' do
      it 'calls the logger and returns an empty array' do
        not_found_response = Net::HTTPResponse.new(1.0, 404, 'not found')
        allow(HTTParty).to(receive(:get)).once { not_found_response }

        expect(Rails.logger).to(receive(:error)).once
        expect(described_class.instance.projects(azure_account)).to eq []
      end
    end
  end
end
