# frozen_string_literal: true

# == Schema Information
#
# Table name: jira_project_configs
#
#  created_at             :datetime         not null
#  fix_version_name       :string           not null, indexed => [project_id]
#  id                     :bigint(8)        not null, primary key
#  jira_product_config_id :integer          not null
#  project_id             :integer          not null, indexed, indexed => [fix_version_name]
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_jira_project_configs_on_project_id                       (project_id)
#  index_jira_project_configs_on_project_id_and_fix_version_name  (project_id,fix_version_name) UNIQUE
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

    validates :project, :fix_version_name, :jira_product_config, presence: true

    validates :fix_version_name, uniqueness: { scope: :project, message: I18n.t('jira_project_config.validations.fix_version_name_uniqueness.message') }
  end
end
