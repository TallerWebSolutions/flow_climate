# frozen-string-literal: true

class ContractService
  include Singleton

  def update_demands(contract)
    contract_demands = contract.customer.demands.where(contract: nil).to_dates(contract.start_date, contract.end_date)

    jira_account = contract.company.jira_accounts.first

    contract_demands.each { |demand| Jira::ProcessJiraIssueJob.perform_later(jira_account, demand.project, demand.external_id, '', '', '') }
  end
end
