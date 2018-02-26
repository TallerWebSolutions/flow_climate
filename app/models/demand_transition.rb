# frozen_string_literal: true

# == Schema Information
#
# Table name: demand_transitions
#
#  id            :integer          not null, primary key
#  demand_id     :integer          not null
#  stage_id      :integer          not null
#  last_time_in  :datetime         not null
#  last_time_out :datetime
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
# Indexes
#
#  index_demand_transitions_on_demand_id  (demand_id)
#  index_demand_transitions_on_stage_id   (stage_id)
#
# Foreign Keys
#
#  fk_rails_...  (demand_id => demands.id)
#  fk_rails_...  (stage_id => stages.id)
#

class DemandTransition < ApplicationRecord
  belongs_to :demand
  belongs_to :stage

  validates :demand, :stage, :last_time_in, presence: true
end
