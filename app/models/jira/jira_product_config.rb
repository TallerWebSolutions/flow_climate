# frozen_string_literal: true

# == Schema Information
#
# Table name: jira_product_configs
#
#  company_id       :integer          not null, indexed, indexed => [jira_product_key]
#  created_at       :datetime         not null
#  id               :bigint(8)        not null, primary key
#  jira_product_key :string           not null, indexed => [company_id]
#  product_id       :integer          not null, indexed
#  updated_at       :datetime         not null
#
# Foreign Keys
#
#  fk_rails_3b969f1e33  (company_id => companies.id)
#  fk_rails_c55dd7e748  (product_id => products.id)
#

module Jira
  class JiraProductConfig < ApplicationRecord
    belongs_to :company
    belongs_to :product

    has_many :jira_project_configs, class_name: 'Jira::JiraProjectConfig', dependent: :destroy

    validates :jira_product_key, :product, :company, presence: true

    validates :jira_product_key, uniqueness: { scope: :product, message: I18n.t('jira_product_config.validations.jira_product_key_uniqueness.message') }
  end
end
