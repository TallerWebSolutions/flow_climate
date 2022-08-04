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

        expect(Customer.all.map(&:name)).to eq ['Wakanda']
      end
    end

    context 'with an already registered customer' do
      it 'uses the registered information' do
        company = Fabricate :company
        Fabricate :customer, company: company, name: 'Beer'
        azure_item_return = file_fixture('azure_work_item_1_expanded.json').read

        described_class.instance.read_customer(company, JSON.parse(azure_item_return))

        expect(Customer.all.count).to eq 1
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

    context 'without the initiative in the payload' do
      it 'reads a default initiative' do
        company = Fabricate :company
        azure_item_return = file_fixture('azure_work_item_2_expanded.json').read

        described_class.instance.read_initiative(company, JSON.parse(azure_item_return))

        expect(Initiative.all.count).to be_zero
      end
    end

    context 'with an already registered initiative' do
      it 'uses the registered information' do
        company = Fabricate :company
        Fabricate :initiative, company: company, name: 'Q1/2023'
        azure_item_return = file_fixture('azure_work_item_1_expanded.json').read

        described_class.instance.read_initiative(company, JSON.parse(azure_item_return))

        expect(Initiative.all.count).to eq 1
      end
    end
  end

  describe '#read_card_type' do
    context 'with the type information' do
      it 'reads the card type inside the payload' do
        company = Fabricate :company
        azure_item_return = file_fixture('azure_work_item_1_expanded.json').read

        described_class.instance.read_card_type(company, JSON.parse(azure_item_return), :demand)

        expect(WorkItemType.all.map(&:name)).to eq ['AV']
      end
    end

    context 'without the type information' do
      it 'reads a default type' do
        company = Fabricate :company
        azure_item_return = file_fixture('azure_work_item_2_expanded.json').read

        described_class.instance.read_card_type(company, JSON.parse(azure_item_return), :task)

        expect(WorkItemType.all.map(&:name)).to eq ['Default']
      end
    end
  end

  describe '#read_project' do
    context 'with one project custom field' do
      it 'reads the project field' do
        company = Fabricate :company
        azure_account = Fabricate :azure_account, company: company
        Fabricate :azure_custom_field, custom_field_type: :project_name, custom_field_name: 'Custom.ProjectName', azure_account: azure_account

        customer = Fabricate :customer, company: company, name: 'The Customer'
        initiative = Fabricate :initiative, company: company, name: 'The Initiative'
        team = Fabricate :team, company: company, name: 'The Team'

        azure_item_return = file_fixture('azure_work_item_2_expanded.json').read

        described_class.instance.read_project(company, customer, team, initiative, azure_account, JSON.parse(azure_item_return))

        expect(Project.all.map(&:name)).to eq ['FlowClimate']
      end
    end

    context 'with two project custom fields' do
      it 'reads the project field concatenating the value in the two fields' do
        company = Fabricate :company
        azure_account = Fabricate :azure_account, company: company
        Fabricate :azure_custom_field, custom_field_type: :project_name, custom_field_name: 'Custom.ProjectName', azure_account: azure_account, field_order: 0
        Fabricate :azure_custom_field, custom_field_type: :project_name, custom_field_name: 'Custom.Category', azure_account: azure_account, field_order: 1

        customer = Fabricate :customer, company: company, name: 'The Customer'
        initiative = Fabricate :initiative, company: company, name: 'The Initiative'
        team = Fabricate :team, company: company, name: 'The Team'

        azure_item_return = file_fixture('azure_work_item_2_expanded.json').read

        described_class.instance.read_project(company, customer, team, initiative, azure_account, JSON.parse(azure_item_return))

        expect(Project.all.map(&:name)).to eq ['FlowClimate - Wakanda']
      end
    end

    context 'with no project custom field' do
      it 'reads the project field' do
        company = Fabricate :company
        azure_account = Fabricate :azure_account, company: company

        customer = Fabricate :customer, company: company, name: 'The Customer'
        initiative = Fabricate :initiative, company: company, name: 'The Initiative'
        team = Fabricate :team, company: company, name: 'The Team'

        azure_item_return = file_fixture('azure_work_item_2_expanded.json').read

        described_class.instance.read_project(company, customer, team, initiative, azure_account, JSON.parse(azure_item_return))

        expect(Project.all.map(&:name)).to eq ['Other - The Team']
      end
    end
  end

  describe '#read_assigned' do
    context 'with the responsible information' do
      it 'reads the team member inside the payload' do
        company = Fabricate :company
        team = Fabricate :team, company: company
        demand = Fabricate :demand, company: company, team: team
        azure_item_return = file_fixture('azure_work_item_1_expanded.json').read

        described_class.instance.read_assigned(company, team, demand, JSON.parse(azure_item_return))

        expect(TeamMember.all.map(&:name)).to eq ['Foo Bar']
      end
    end

    context 'without the assigned information' do
      it 'reads a default type' do
        company = Fabricate :company
        azure_item_return = file_fixture('azure_work_item_2_expanded.json').read

        described_class.instance.read_card_type(company, JSON.parse(azure_item_return), :task)

        expect(WorkItemType.all.map(&:name)).to eq ['Default']
      end
    end
  end

  describe '#read_tags' do
    context 'with data' do
      it 'returns the array of tags' do
        item_response = { 'fields' => { 'System.Tags' => 'xpto ; foo' } }

        expect(described_class.instance.read_tags(item_response)).to eq %w[xpto foo]
      end
    end

    context 'with no data' do
      it 'returns an empty array' do
        item_response = {}

        expect(described_class.instance.read_tags(item_response)).to eq []
      end
    end

    context 'with no System.Tags field' do
      it 'returns an empty array' do
        item_response = { 'fields' => {} }

        expect(described_class.instance.read_tags(item_response)).to eq []
      end
    end
  end
end
