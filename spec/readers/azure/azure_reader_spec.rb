# frozen_string_literal: true

RSpec.describe Azure::AzureReader, type: :service do
  describe '#read_team' do
    context 'with no team custom field' do
      it 'does not read the team information from the azure payload' do
        company = Fabricate :company
        azure_account = Fabricate :azure_account, company: company
        azure_item_return = file_fixture('azure_work_item_1_expanded.json').read

        described_class.instance.read_team(company, azure_account, JSON.parse(azure_item_return))

        expect(Team.all.count).to eq 0
      end
    end

    context 'with a team custom field' do
      it 'reads the team information from the azure payload' do
        company = Fabricate :company
        azure_account = Fabricate :azure_account, company: company
        Fabricate :azure_custom_field, custom_field_type: :team_name, custom_field_name: 'Custom.AgencyName', azure_account: azure_account
        azure_item_return = file_fixture('azure_work_item_1_expanded.json').read

        described_class.instance.read_team(company, azure_account, JSON.parse(azure_item_return))

        expect(Team.all.map(&:name)).to eq ['Air Force Cloud One']
      end
    end

    context 'with a team custom field and without the team in the payload' do
      it 'reads a default team' do
        company = Fabricate :company
        azure_account = Fabricate :azure_account, company: company
        Fabricate :azure_custom_field, custom_field_type: :team_name, custom_field_name: 'Custom.AgencyName', azure_account: azure_account
        azure_item_return = file_fixture('azure_work_item_2_expanded.json').read

        described_class.instance.read_team(company, azure_account, JSON.parse(azure_item_return))

        expect(Team.all.map(&:name)).to eq ['Default Team']
      end
    end
  end

  describe '#read_customer' do
    context 'with the customer information inside the payload' do
      it 'reads the customer' do
        company = Fabricate :company
        azure_item_return = file_fixture('azure_work_item_1_expanded.json').read

        described_class.instance.read_customer(company, JSON.parse(azure_item_return))

        expect(Customer.all.map(&:name)).to eq ['Beer']
      end
    end

    context 'without the customer in the payload' do
      it 'reads a default customer' do
        company = Fabricate :company
        azure_item_return = file_fixture('azure_work_item_2_expanded.json').read

        described_class.instance.read_customer(company, JSON.parse(azure_item_return))

        expect(Customer.all.map(&:name)).to eq ['Default Customer']
      end
    end
  end

  describe '#read_initiative' do
    context 'with the initiative information inside the payload' do
      it 'reads the initiative' do
        company = Fabricate :company
        azure_item_return = file_fixture('azure_work_item_1_expanded.json').read

        described_class.instance.read_initiative(company, JSON.parse(azure_item_return))

        expect(Initiative.all.map(&:name)).to eq ['Q1/2023']
      end
    end

    context 'without the customer in the payload' do
      it 'reads a default customer' do
        company = Fabricate :company
        azure_item_return = file_fixture('azure_work_item_2_expanded.json').read

        described_class.instance.read_initiative(company, JSON.parse(azure_item_return))

        expect(Initiative.all.count).to be_zero
      end
    end
  end
  
  pending '#read_card_type'
  pending '#read_project'
end
