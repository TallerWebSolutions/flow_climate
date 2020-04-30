# frozen_string_literal: true

# == Schema Information
#
# Table name: devise_customers
#
#  id                     :bigint           not null, primary key
#  current_sign_in_at     :datetime
#  current_sign_in_ip     :inet
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  first_name             :string           not null
#  last_name              :string           not null
#  last_sign_in_at        :datetime
#  last_sign_in_ip        :inet
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  sign_in_count          :integer          default(0), not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_devise_customers_on_email                 (email) UNIQUE
#  index_devise_customers_on_reset_password_token  (reset_password_token) UNIQUE
#
class DeviseCustomer < ApplicationRecord
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :validatable, :trackable, :validatable

  has_and_belongs_to_many :customers, dependent: :destroy

  validates :first_name, :last_name, :email, presence: true
end
