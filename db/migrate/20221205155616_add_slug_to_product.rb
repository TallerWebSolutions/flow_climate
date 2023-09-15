# frozen_string_literal: true

class AddSlugToProduct < ActiveRecord::Migration[7.0]
  def change
    add_column :products, :slug, :string

    Product.find_each { |p| p.update(slug: p.name.parameterize) }

    change_column_null :products, :slug, false
    add_index :products, %i[company_id slug], unique: true
  end
end
