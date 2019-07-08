# frozen_string_literal: true

# == Schema Information
#
# Table name: demand_comments
#
#  comment_date   :datetime         not null
#  comment_text   :string           not null
#  created_at     :datetime         not null
#  demand_id      :integer          not null, indexed
#  id             :bigint(8)        not null, primary key
#  team_member_id :integer
#  updated_at     :datetime         not null
#
# Indexes
#
#  index_demand_comments_on_demand_id  (demand_id)
#
# Foreign Keys
#
#  fk_rails_b68ee35cab  (team_member_id => team_members.id)
#  fk_rails_dc14d53db5  (demand_id => demands.id)
#

class DemandComment < ApplicationRecord
  belongs_to :demand
  belongs_to :team_member

  validates :demand, :comment_date, :comment_text, presence: true
end
