# frozen_string_literal: true

module Types
  class ProductType < Types::BaseObject
    field :company, Types::CompanyType, null: true
    field :id, ID, null: false
    field :name, String, null: false
    field :slug, String, null: false
  end
end
