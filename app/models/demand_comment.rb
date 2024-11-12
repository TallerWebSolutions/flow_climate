# frozen_string_literal: true

# == Schema Information
#
# Table name: demand_comments
#
#  id             :integer          not null, primary key
#  demand_id      :integer          not null
#  comment_date   :datetime         not null
#  comment_text   :string           not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  team_member_id :integer
#  discarded_at   :datetime
#
# Indexes
#
#  index_demand_comments_on_demand_id  (demand_id)
#

class DemandComment < ApplicationRecord
  include Discard::Model

  belongs_to :demand
  belongs_to :team_member

  validates :comment_date, :comment_text, presence: true
end
