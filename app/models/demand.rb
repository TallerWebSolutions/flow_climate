# frozen_string_literal: true

# == Schema Information
#
# Table name: demands
#
#  id                :integer          not null, primary key
#  project_result_id :integer          not null
#  demand_id         :string           not null
#  effort            :decimal(, )      not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
# Indexes
#
#  index_demands_on_project_result_id  (project_result_id)
#

class Demand < ApplicationRecord
  belongs_to :project_result, counter_cache: true

  validates :demand_id, :effort, presence: true
end
