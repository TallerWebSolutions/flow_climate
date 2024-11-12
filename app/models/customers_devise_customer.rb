# frozen_string_literal: true

# == Schema Information
#
# Table name: customers_devise_customers
#
#  id                 :integer          not null, primary key
#  customer_id        :integer          not null
#  devise_customer_id :integer          not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#
# Indexes
#
#  idx_customers_devise_customer_unique                    (customer_id,devise_customer_id) UNIQUE
#  index_customers_devise_customers_on_customer_id         (customer_id)
#  index_customers_devise_customers_on_devise_customer_id  (devise_customer_id)
#

class CustomersDeviseCustomer < ApplicationRecord
  belongs_to :customer
  belongs_to :devise_customer
end
