# frozen_string_literal: true

class RemoveCustomerInProductNotNull < ActiveRecord::Migration[6.1]
  def change
    change_column_null :products, :customer_id, true

    add_column :products, :company_id, :integer
    add_index :products, :company_id

    Product.all.each do |product|
      company_id = Customer.find_by(id: product.customer_id).company_id
      product.update(company_id: company_id)
    end

    add_foreign_key :products, :companies, column: :company_id

    change_column_null :products, :company_id, false
  end
end
