# frozen_string_literal: true

# == Schema Information
#
# Table name: projects
#
#  id            :integer          not null, primary key
#  customer_id   :integer          not null
#  name          :string           not null
#  status        :integer          not null
#  start_date    :date             not null
#  end_date      :date             not null
#  value         :decimal(, )
#  qty_hours     :decimal(, )
#  hour_value    :decimal(, )
#  initial_scope :integer          not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
# Indexes
#
#  index_projects_on_customer_id  (customer_id)
#
# Foreign Keys
#
#  fk_rails_...  (customer_id => customers.id)
#

class Project < ApplicationRecord
  enum status: { waiting: 0, executing: 1, finished: 2, cancelled: 3 }

  belongs_to :customer

  validates :name, :start_date, :end_date, :status, :initial_scope, presence: true
end
