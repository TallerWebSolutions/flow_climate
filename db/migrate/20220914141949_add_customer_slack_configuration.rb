class AddCustomerSlackConfiguration < ActiveRecord::Migration[7.0]
  def change
    change_table :slack_configurations, bulk: true do |t|
      t.change_null :team_id, true
      t.integer :customer_id, index: true
      t.integer :config_type, default: 0, index: true
    end
    add_foreign_key :slack_configurations, :customers, column: :customer_id
  end
end
