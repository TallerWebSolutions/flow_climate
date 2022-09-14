# frozen_string_literal: true

# == Schema Information
#
# Table name: demand_comments
#
#  id             :bigint           not null, primary key
#  comment_date   :datetime         not null
#  comment_text   :string           not null
#  discarded_at   :datetime
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  demand_id      :integer          not null
#  team_member_id :integer
#
# Indexes
#
#  index_demand_comments_on_demand_id       (demand_id)
#  index_demand_comments_on_discarded_at    (discarded_at)
#  index_demand_comments_on_team_member_id  (team_member_id)
#
# Foreign Keys
#
#  fk_rails_b68ee35cab  (team_member_id => team_members.id)
#  fk_rails_dc14d53db5  (demand_id => demands.id)
#

class DemandComment < ApplicationRecord
  include Discard::Model

  belongs_to :demand
  belongs_to :team_member

  validates :comment_date, :comment_text, presence: true
end
