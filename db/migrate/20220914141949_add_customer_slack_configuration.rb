class AddCustomerSlackConfiguration < ActiveRecord::Migration[7.0]
  def change
    change_column_null :slack_configurations, :team_id, true
    add_column :slack_configurations, :customer_id, :integer, null: true
    add_index :slack_configurations, :customer_id
    add_foreign_key :slack_configurations, :customers, column: :customer_id
  end
end
