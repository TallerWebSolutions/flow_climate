# frozen_string_literal: true

module Types
  class WorkItemTypeType < Types::BaseObject
    field :id, ID, null: false
    field :name, String, null: false
    field :item_level, Types::Enums::WorkItemLevel, null: false
    field :quality_indicator_type, Boolean, null: false
  end
end
