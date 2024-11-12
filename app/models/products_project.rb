# frozen_string_literal: true

# == Schema Information
#
# Table name: products_projects
#
#  id         :integer          not null, primary key
#  product_id :integer          not null
#  project_id :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_products_projects_on_product_id                 (product_id)
#  index_products_projects_on_product_id_and_project_id  (product_id,project_id) UNIQUE
#  index_products_projects_on_project_id                 (project_id)
#

class ProductsProject < ApplicationRecord
  belongs_to :product
  belongs_to :project
end
