# frozen_string_literal: true

# == Schema Information
#
# Table name: jira_project_configs
#
#  id                     :bigint           not null, primary key
#  fix_version_name       :string           not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  jira_product_config_id :integer          not null
#  project_id             :integer          not null
#
# Indexes
#
#  index_jira_project_configs_on_project_id  (project_id)
#  unique_fix_version_to_jira_product        (jira_product_config_id,fix_version_name) UNIQUE
#
# Foreign Keys
#
#  fk_rails_039cb02c5a  (jira_product_config_id => jira_product_configs.id)
#  fk_rails_5de62c9ca2  (project_id => projects.id)
#

module Jira
  class JiraProjectConfig < ApplicationRecord
    belongs_to :project
    belongs_to :jira_product_config, class_name: 'Jira::JiraProductConfig'

    validates :fix_version_name, presence: true

    validates :fix_version_name, uniqueness: { scope: :jira_product_config, message: I18n.t('jira_project_config.validations.fix_version_name_uniqueness.message') }
  end
end
