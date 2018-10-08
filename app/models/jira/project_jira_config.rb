# frozen_string_literal: true

# == Schema Information
#
# Table name: project_jira_configs
#
#  active              :boolean          default(TRUE), not null
#  created_at          :datetime         not null
#  fix_version_name    :string           indexed => [jira_project_key, jira_account_domain]
#  id                  :bigint(8)        not null, primary key
#  jira_account_domain :string           not null, indexed, indexed => [jira_project_key, fix_version_name]
#  jira_project_key    :string           not null, indexed, indexed => [jira_account_domain, fix_version_name]
#  project_id          :integer          not null, indexed
#  team_id             :integer          not null, indexed
#  updated_at          :datetime         not null
#
# Indexes
#
#  index_project_jira_configs_on_jira_account_domain  (jira_account_domain)
#  index_project_jira_configs_on_jira_project_key     (jira_project_key)
#  index_project_jira_configs_on_project_id           (project_id)
#  index_project_jira_configs_on_team_id              (team_id)
#  unique_jira_project_key_to_jira_account_domain     (jira_project_key,jira_account_domain,fix_version_name) UNIQUE
#
# Foreign Keys
#
#  fk_rails_5de62c9ca2  (project_id => projects.id)
#  fk_rails_b2aa7aacef  (team_id => teams.id)
#

module Jira
  class ProjectJiraConfig < ApplicationRecord
    belongs_to :project
    belongs_to :team

    validates :project, :team, :jira_account_domain, :jira_project_key, presence: true

    validates :jira_project_key, uniqueness: { scope: %i[jira_account_domain fix_version_name], message: I18n.t('project_jira_config.validations.jira_project_key_uniqueness.message') }
  end
end
