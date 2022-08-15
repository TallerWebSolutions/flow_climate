# == Schema Information
#
# Table name: jira_api_errors
#
#  id         :bigint           not null, primary key
#  processed  :boolean          default(FALSE)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  demand_id  :integer          not null
#
# Indexes
#
#  index_jira_api_errors_on_demand_id  (demand_id)
#
# Foreign Keys
#
#  fk_rails_cc434c098b  (demand_id => demands.id)
#
# frozen_string_literal: true

module Jira
  class JiraApiError < ApplicationRecord
    belongs_to :demand
  end
end
