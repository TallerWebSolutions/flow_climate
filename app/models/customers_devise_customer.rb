# frozen_string_literal: true

# == Schema Information
#
# Table name: customers_devise_customers
#
#  id                 :bigint           not null, primary key
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  customer_id        :integer          not null
#  devise_customer_id :integer          not null
#
# Indexes
#
#  idx_customers_devise_customer_unique                    (customer_id,devise_customer_id) UNIQUE
#  index_customers_devise_customers_on_customer_id         (customer_id)
#  index_customers_devise_customers_on_devise_customer_id  (devise_customer_id)
#
# Foreign Keys
#
#  fk_rails_49f9a1ee28  (customer_id => customers.id)
#  fk_rails_9c6f3519a8  (devise_customer_id => dashboard.id)
#
class CustomersDeviseCustomer < ApplicationRecord
  belongs_to :customer
  belongs_to :devise_customer
end
