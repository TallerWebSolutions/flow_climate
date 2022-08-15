# frozen_string_literal: true

RSpec.describe ContractService, type: :service do
  describe '#update_demands' do
    context 'with end_date in contract' do
      it 'calls the job to update the contract in the demand' do
        jira_account = instance_double(Jira::JiraAccount)
        company = instance_double(Company)
        demand = Fabricate :demand
        customer = instance_double(Customer, demands: Demand.where(id: demand.id))
        contract = instance_double(Contract, company: company, customer: customer, start_date: 2.days.ago, end_date: Time.zone.today)

        allow(company).to(receive(:jira_accounts)).and_return([jira_account])
        allow(Demand).to(receive(:to_dates)).and_return([demand])
        expect(Jira::ProcessJiraIssueJob).to(receive(:perform_later)).once

        described_class.instance.update_demands(contract)
      end
    end

    context 'with no end_date in contract' do
      it 'calls the job to update the contract in the demand using today as date' do
        jira_account = instance_double(Jira::JiraAccount)
        company = instance_double(Company)
        demand = Fabricate :demand
        customer = instance_double(Customer, demands: Demand.where(id: demand.id))
        contract = instance_double(Contract, company: company, customer: customer, start_date: 2.days.ago, end_date: nil)

        allow(company).to(receive(:jira_accounts)).and_return([jira_account])
        allow(Demand).to(receive(:to_dates)).and_return([demand])
        expect(Jira::ProcessJiraIssueJob).to(receive(:perform_later)).once

        described_class.instance.update_demands(contract)
      end
    end
  end
end
