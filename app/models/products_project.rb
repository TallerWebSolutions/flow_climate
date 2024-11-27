# frozen_string_literal: true

# == Schema Information
#
# Table name: products_projects
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  product_id :integer          not null
#  project_id :integer          not null
#
# Indexes
#
#  index_products_projects_on_product_id                 (product_id)
#  index_products_projects_on_product_id_and_project_id  (product_id,project_id) UNIQUE
#  index_products_projects_on_project_id                 (project_id)
#
# Foreign Keys
#
#  fk_rails_170b9c6651  (project_id => projects.id)
#  fk_rails_c648f2cd3e  (product_id => products.id)
#

class ProductsProject < ApplicationRecord
  belongs_to :product
  belongs_to :project
end
