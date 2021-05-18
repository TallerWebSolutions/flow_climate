# frozen_string_literal: true

# == Schema Information
#
# Table name: customers_projects
#
#  id          :bigint           not null, primary key
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  customer_id :integer          not null
#  project_id  :integer          not null
#
# Indexes
#
#  index_customers_projects_on_customer_id                 (customer_id)
#  index_customers_projects_on_customer_id_and_project_id  (customer_id,project_id) UNIQUE
#  index_customers_projects_on_project_id                  (project_id)
#
# Foreign Keys
#
#  fk_rails_9b68bbaf49  (customer_id => customers.id)
#  fk_rails_ee14b8e6f4  (project_id => projects.id)
#
class CustomersProject < ApplicationRecord
  belongs_to :customer
  belongs_to :project

  validates :customer, :project, presence: true
end
