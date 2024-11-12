# frozen_string_literal: true

# == Schema Information
#
# Table name: jira_project_configs
#
#  id                     :integer          not null, primary key
#  project_id             :integer          not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  fix_version_name       :string           not null
#  jira_product_config_id :integer          not null
#
# Indexes
#
#  index_jira_project_configs_on_project_id  (project_id)
#  unique_fix_version_to_jira_product        (jira_product_config_id,fix_version_name) UNIQUE
#

module Jira
  class JiraProjectConfig < ApplicationRecord
    belongs_to :project
    belongs_to :jira_product_config, class_name: 'Jira::JiraProductConfig'

    validates :fix_version_name, presence: true

    validates :fix_version_name, uniqueness: { scope: :jira_product_config, message: I18n.t('jira_project_config.validations.fix_version_name_uniqueness.message') }
  end
end
