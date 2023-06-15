# frozen_string_literal: true

module Types
  class JiraProjectConfigType < Types::BaseObject
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :fix_version_name, String, null: false
    field :id, ID, null: false
    field :jira_product_config, Types::JiraProductConfigType, null: false
    field :project, Types::ProjectType, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
  end
end
