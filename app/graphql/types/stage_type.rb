# frozen_string_literal: true

module Types
  class StageType < Types::BaseObject
    field :id, ID, null: false
    field :integration_id, String, null: false
    field :name, String, null: false
    field :stage_type, Integer, null: false
    field :stage_stream, Integer, null: false
    field :commitment_point, Boolean
    field :end_point, Boolean
    field :queue, Boolean
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
    field :company_id, Integer, null: false
    field :order, Integer, null: false
    field :integration_pipe_id, String
    field :parent_id, Integer
    field :stage_level, Integer, null: false
  end
end
