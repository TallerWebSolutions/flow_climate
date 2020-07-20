# frozen-string-literal: true

# == Schema Information
#
# Table name: demand_transition_notifications
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  demand_id  :integer          not null
#  stage_id   :integer          not null
#
# Indexes
#
#  idx_demand_transtions_notifications                 (demand_id,stage_id)
#  index_demand_transition_notifications_on_demand_id  (demand_id)
#  index_demand_transition_notifications_on_stage_id   (stage_id)
#
# Foreign Keys
#
#  fk_rails_3ae7fb6c0f  (stage_id => stages.id)
#  fk_rails_903f0b082b  (demand_id => demands.id)
#

class DemandTransitionNotification < ApplicationRecord
  belongs_to :stage
  belongs_to :demand

  validates :stage, :demand, presence: true
  validates :stage, uniqueness: { scope: :demand, message: I18n.t('demand_transition_notification.validations.stage.uniqueness') }
end
