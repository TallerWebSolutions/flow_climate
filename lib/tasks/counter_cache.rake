# frozen_string_literal: true

desc 'Counter cache for project has many tasks'

task counter_caches_reset: :environment do
  Customer.reset_column_information
  Customer.map(&:id).each do |customer_id|
    Customer.reset_counters(customer_id, :products)
    Customer.reset_counters(customer_id, :projects)
  end

  Product.reset_column_information
  Product.map(&:id).each do |product|
    Product.reset_counters product, :projects
  end

  Company.reset_column_information
  Company.map(&:id).each do |company_id|
    Company.reset_counters company_id, :customers
  end
end
