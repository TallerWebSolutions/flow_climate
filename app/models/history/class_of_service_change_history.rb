# frozen_string_literal: true

# == Schema Information
#
# Table name: class_of_service_change_histories
#
#  id                    :bigint           not null, primary key
#  change_date           :datetime         not null
#  from_class_of_service :integer
#  to_class_of_service   :integer          not null
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  demand_id             :integer          not null
#
# Indexes
#
#  cos_history_unique                                    (demand_id,change_date) UNIQUE
#  index_class_of_service_change_histories_on_demand_id  (demand_id)
#
# Foreign Keys
#
#  fk_rails_b150af85df  (demand_id => demands.id)
#

module History
  class ClassOfServiceChangeHistory < ApplicationRecord
    enum :from_class_of_service, { from_standard: 0, from_expedite: 1, from_fixed_date: 2, from_intangible: 3 }
    enum :to_class_of_service, { to_standard: 0, to_expedite: 1, to_fixed_date: 2, to_intangible: 3 }

    belongs_to :demand

    validates :change_date, :to_class_of_service, presence: true
    validates :demand, uniqueness: { scope: :change_date }
  end
end
