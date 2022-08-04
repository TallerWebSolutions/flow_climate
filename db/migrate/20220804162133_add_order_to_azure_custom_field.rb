# frozen_string_literal: true

class AddOrderToAzureCustomField < ActiveRecord::Migration[7.0]
  def change
    add_column :azure_custom_fields, :field_order, :integer, default: 0, null: false
  end
end
