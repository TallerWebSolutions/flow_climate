# frozen_string_literal: true

# == Schema Information
#
# Table name: project_jira_configs
#
#  active          :boolean          default(TRUE), not null
#  created_at      :datetime         not null
#  id              :bigint(8)        not null, primary key
#  jira_account_id :integer          not null, indexed
#  project_id      :integer          not null, indexed
#  team_id         :integer          not null, indexed
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_project_jira_configs_on_jira_account_id  (jira_account_id)
#  index_project_jira_configs_on_project_id       (project_id)
#  index_project_jira_configs_on_team_id          (team_id)
#
# Foreign Keys
#
#  fk_rails_5de62c9ca2  (project_id => projects.id)
#  fk_rails_b2aa7aacef  (team_id => teams.id)
#  fk_rails_feeb7c589a  (jira_account_id => jira_accounts.id)
#

module Jira
  class ProjectJiraConfig < ApplicationRecord
    belongs_to :jira_account, class_name: 'Jira::JiraAccount'

    belongs_to :project
    belongs_to :team

    validates :project, :jira_account, :team, presence: true
  end
end
