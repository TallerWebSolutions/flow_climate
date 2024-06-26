# frozen_string_literal: true

class AddCustomerToDemand < ActiveRecord::Migration[6.0]
  def change
    add_column :demands, :customer_id, :integer
    add_index :demands, :customer_id

    add_foreign_key :demands, :customers, columm: :customer_id

    Customer.find_each do |customer|
      customer.exclusive_projects.each do |project|
        project.demands.each do |demand|
          demand.update(customer: project.customers.first)
        end
      end
    end
  end
end
