# frozen_string_literal: true

# == Schema Information
#
# Table name: product_users
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  product_id :integer          not null
#  user_id    :integer          not null
#
# Indexes
#
#  index_product_users_on_product_id              (product_id)
#  index_product_users_on_product_id_and_user_id  (product_id,user_id) UNIQUE
#  index_product_users_on_user_id                 (user_id)
#
# Foreign Keys
#
#  fk_rails_24c98a63d7  (user_id => users.id)
#  fk_rails_4ffaf81a97  (product_id => products.id)
#
class ProductUser < ApplicationRecord
  belongs_to :product
  belongs_to :user

  validates :product_id, uniqueness: { scope: :user_id }
end
