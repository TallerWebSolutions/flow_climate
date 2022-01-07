# frozen_string_literal: true

# == Schema Information
#
# Table name: customer_consolidations
#
#  id                                  :bigint           not null, primary key
#  average_consumed_hours_in_month     :decimal(, )      default(0.0)
#  consolidation_date                  :date             not null
#  consumed_hours                      :decimal(, )      default(0.0)
#  consumed_hours_in_month             :decimal(, )      default(0.0)
#  design_consumed_hours               :decimal(, )      default(0.0), not null
#  design_consumed_hours_in_month      :decimal(, )      default(0.0), not null
#  development_consumed_hours          :decimal(, )      default(0.0), not null
#  development_consumed_hours_in_month :decimal(, )      default(0.0), not null
#  flow_pressure                       :decimal(, )      default(0.0)
#  hours_per_demand                    :decimal(, )      default(0.0)
#  hours_per_demand_in_month           :decimal(, )      default(0.0)
#  last_data_in_month                  :boolean          default(FALSE)
#  last_data_in_week                   :boolean          default(FALSE)
#  last_data_in_year                   :boolean          default(FALSE)
#  lead_time_p80                       :decimal(, )      default(0.0)
#  lead_time_p80_in_month              :decimal(, )      default(0.0)
#  management_consumed_hours           :decimal(, )      default(0.0), not null
#  management_consumed_hours_in_month  :decimal(, )      default(0.0), not null
#  qty_demands_committed               :integer          default(0)
#  qty_demands_created                 :integer          default(0)
#  qty_demands_finished                :integer          default(0)
#  value_per_demand                    :decimal(, )      default(0.0)
#  value_per_demand_in_month           :decimal(, )      default(0.0)
#  created_at                          :datetime         not null
#  updated_at                          :datetime         not null
#  customer_id                         :integer          not null
#
# Indexes
#
#  customer_consolidation_unique                        (customer_id,consolidation_date) UNIQUE
#  index_customer_consolidations_on_customer_id         (customer_id)
#  index_customer_consolidations_on_last_data_in_month  (last_data_in_month)
#  index_customer_consolidations_on_last_data_in_week   (last_data_in_week)
#  index_customer_consolidations_on_last_data_in_year   (last_data_in_year)
#
# Foreign Keys
#
#  fk_rails_34ed62881e  (customer_id => customers.id)
#
module Consolidations
  class CustomerConsolidation < ApplicationRecord
    belongs_to :customer

    scope :monthly_data, -> { where(last_data_in_month: true) }

    validates :consolidation_date, presence: true
    validates :customer, uniqueness: { scope: :consolidation_date }
  end
end
