# frozen_string_literal: true

desc 'Update partial efforts'

namespace :demands do
  task update_partial_effort: :environment do
    return unless Time.zone.now.hour.between?(8, 21)

    Demand.kept.in_flow(Time.zone.now).each do |demand|
      jira_account = demand.company.jira_accounts.first

      if jira_account.present?
        Jira::ProcessJiraIssueJob.perform_later(demand.external_id, jira_account, demand.project, '', '', '')
      else
        demand.discard
      end
    end
  end
end
