# frozen_string_literal: true

class AddCustomerToDemand < ActiveRecord::Migration[6.0]
  def change
    add_column :demands, :customer_id, :integer, index: true

    add_foreign_key :demands, :customers, columm: :customer_id

    Customer.all.each do |customer|
      customer.exclusive_projects.each do |project|
        project.demands.each do |demand|
          demand.update(customer: project.customers.first)
        end
      end
    end
  end
end
