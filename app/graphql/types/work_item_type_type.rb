# frozen_string_literal: true

module Types
  class WorkItemTypeType < Types::BaseObject
    field :id, ID, null: false
    field :name, String, null: false
    field :item_level, Types::Enums::WorkItemLevel, null: false
    field :quality_indicator_type, Boolean, null: false

    def item_level
      return "DEMAND" if object.item_level === 0
      "TASK"
    end
  end
end
