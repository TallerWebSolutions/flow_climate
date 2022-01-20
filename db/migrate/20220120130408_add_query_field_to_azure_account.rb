# frozen_string_literal: true

class AddQueryFieldToAzureAccount < ActiveRecord::Migration[6.1]
  def change
    add_column :azure_accounts, :azure_work_item_query, :string
  end
end
