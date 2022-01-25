# frozen_string_literal: true

# == Schema Information
#
# Table name: tasks
#
#  id                  :bigint           not null, primary key
#  created_date        :datetime         not null
#  end_date            :datetime
#  seconds_to_complete :integer
#  title               :string           not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  demand_id           :integer          not null
#  external_id         :integer
#
# Indexes
#
#  index_tasks_on_demand_id  (demand_id)
#
# Foreign Keys
#
#  fk_rails_ae3913c114  (demand_id => demands.id)
#
class Task < ApplicationRecord
  belongs_to :demand

  validates :title, :created_date, presence: true
end
