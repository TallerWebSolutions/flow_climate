# frozen_string_literal: true

module Mutations
  class ToggleProductUserMutation < Mutations::BaseMutation
    argument :product_id, ID, required: true
    argument :user_id, ID, required: true

    field :product, Types::ProductType, null: true
    field :status_message, String, null: false

    def resolve(product_id:, user_id:)
      product = Product.find_by(id: product_id)
      user = User.find_by(id: user_id)

      if product.present? && user.present?
        product_user = ProductUser.find_by(product: product, user: user)

        if product_user.present?
          product_user.destroy
        else
          ProductUser.create(product: product, user: user)
        end
        { product: product, status_message: 'SUCCESS' }
      else
        { status_message: 'NOT_FOUND' }
      end
    end
  end
end
