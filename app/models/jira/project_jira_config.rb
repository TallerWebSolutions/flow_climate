# frozen_string_literal: true

# == Schema Information
#
# Table name: project_jira_configs
#
#  created_at       :datetime         not null
#  fix_version_name :string
#  id               :bigint(8)        not null, primary key
#  jira_project_key :string           not null, indexed
#  project_id       :integer          not null, indexed
#  updated_at       :datetime         not null
#
# Indexes
#
#  index_project_jira_configs_on_jira_project_key  (jira_project_key)
#  index_project_jira_configs_on_project_id        (project_id)
#
# Foreign Keys
#
#  fk_rails_5de62c9ca2  (project_id => projects.id)
#

module Jira
  class ProjectJiraConfig < ApplicationRecord
    belongs_to :project

    validates :project, :jira_project_key, presence: true

    validates :jira_project_key, uniqueness: { scope: :project, message: I18n.t('project_jira_config.validations.jira_project_key_uniqueness.message') }
  end
end
