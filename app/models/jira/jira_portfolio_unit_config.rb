# frozen_string_literal: true

# == Schema Information
#
# Table name: jira_portfolio_unit_configs
#
#  created_at        :datetime         not null
#  id                :bigint(8)        not null, primary key
#  jira_field_name   :string           not null
#  portfolio_unit_id :integer          not null, indexed
#  updated_at        :datetime         not null
#
# Indexes
#
#  index_jira_portfolio_unit_configs_on_portfolio_unit_id  (portfolio_unit_id)
#
# Foreign Keys
#
#  fk_rails_36a483c30d  (portfolio_unit_id => portfolio_units.id)
#

module Jira
  class JiraPortfolioUnitConfig < ApplicationRecord
    belongs_to :portfolio_unit

    validates :jira_field_name, :portfolio_unit, presence: true
  end
end
