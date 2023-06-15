# frozen_string_literal: true

module Types
  class JiraProductConfigType < Types::BaseObject
    field :company, Types::CompanyType, null: false
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :id, ID, null: false
    field :jira_product_key, String, null: false
    field :product, Types::ProductType, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
  end
end
