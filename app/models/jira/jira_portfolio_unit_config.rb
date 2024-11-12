# frozen_string_literal: true

# == Schema Information
#
# Table name: jira_portfolio_unit_configs
#
#  id                :integer          not null, primary key
#  portfolio_unit_id :integer          not null
#  jira_field_name   :string           not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
# Indexes
#
#  index_jira_portfolio_unit_configs_on_portfolio_unit_id  (portfolio_unit_id)
#

module Jira
  class JiraPortfolioUnitConfig < ApplicationRecord
    belongs_to :portfolio_unit

    validates :jira_field_name, presence: true
  end
end
