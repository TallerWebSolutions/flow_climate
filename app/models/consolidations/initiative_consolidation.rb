# frozen_string_literal: true

# == Schema Information
#
# Table name: initiative_consolidations
#
#  id                                 :bigint           not null, primary key
#  consolidation_date                 :date             not null
#  last_data_in_month                 :boolean          default(FALSE)
#  last_data_in_week                  :boolean          default(FALSE)
#  last_data_in_year                  :boolean          default(FALSE)
#  tasks_completion_time_p80          :decimal(, )
#  tasks_completion_time_p80_in_month :decimal(, )
#  tasks_completion_time_p80_in_week  :decimal(, )
#  tasks_delivered                    :integer
#  tasks_delivered_in_month           :integer
#  tasks_delivered_in_week            :integer
#  tasks_operational_risk             :decimal(, )
#  tasks_scope                        :integer
#  created_at                         :datetime         not null
#  updated_at                         :datetime         not null
#  initiative_id                      :integer          not null
#
# Indexes
#
#  index_initiative_consolidations_on_consolidation_date  (consolidation_date)
#  index_initiative_consolidations_on_initiative_id       (initiative_id)
#  initiative_consolidation_unique                        (initiative_id,consolidation_date) UNIQUE
#
# Foreign Keys
#
#  fk_rails_3a60bcdf90  (initiative_id => initiatives.id)
#
module Consolidations
  class InitiativeConsolidation < ApplicationRecord
    belongs_to :initiative

    scope :outdated_consolidations, ->(start_date, end_date) { where('initiative_consolidations.consolidation_date < :upper_limit OR initiative_consolidations.consolidation_date > :bottom_limit', upper_limit: start_date, bottom_limit: end_date) }
    scope :weekly_data, -> { where(last_data_in_week: true) }

    validates :consolidation_date, presence: true

    validates :initiative, uniqueness: { scope: :consolidation_date }
  end
end
