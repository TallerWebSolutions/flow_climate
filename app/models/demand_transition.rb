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

  delegate :name, to: :stage, prefix: true
  delegate :compute_effort, to: :stage, prefix: true

  scope :downstream_transitions, -> { joins(:stage).where('stages.stage_stream = :stream', stream: Stage.stage_streams[:downstream]) }

  after_save :set_demand_dates, on: %i[create update]

  def total_time_in_transition
    return 0 if last_time_out.blank?
    (last_time_out - last_time_in) / 1.hour
  end

  def working_time_in_transition
    return 0 if last_time_out.blank?
    TimeService.instance.compute_working_hours_for_dates(last_time_in, last_time_out)
  end

  private

  def set_demand_dates
    if stage.commitment_point?
      demand.update!(commitment_date: last_time_in)
    elsif stage.end_point?
      demand.update!(end_date: last_time_in)
    end
  end
end
