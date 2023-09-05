# frozen_string_literal: true

desc 'Update partial efforts'

namespace :demands do
  task update_partial_effort: :environment do
    return unless Time.zone.now.hour.between?(8, 21)

    Demand.in_flow(Time.zone.now).each do |demand|
      jira_account = demand.company.jira_accounts.first

      if jira_account.present?
        Jira::ProcessJiraIssueJob.perform_later(jira_account, demand.project, demand.external_id, '', '', '')

        DemandEffortService.instance.build_efforts_to_demand(demand)
      else
        demand.destroy
      end
    end
  end
end
