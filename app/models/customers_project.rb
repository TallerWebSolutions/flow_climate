# frozen_string_literal: true

# == Schema Information
#
# Table name: customers_projects
#
#  id          :integer          not null, primary key
#  customer_id :integer          not null
#  project_id  :integer          not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_customers_projects_on_customer_id                 (customer_id)
#  index_customers_projects_on_customer_id_and_project_id  (customer_id,project_id) UNIQUE
#  index_customers_projects_on_project_id                  (project_id)
#

class CustomersProject < ApplicationRecord
  belongs_to :customer
  belongs_to :project
end
