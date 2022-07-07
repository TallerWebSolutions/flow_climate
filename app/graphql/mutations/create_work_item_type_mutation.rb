# frozen_string_literal: true

module Mutations
  class CreateWorkItemTypeMutation < Mutations::BaseMutation
    argument :name, String, required: true
    argument :item_level, Types::Enums::WorkItemLevel, required: true
    argument :quality_indicator_type, Boolean, required: true

    field :work_item_type, Types::WorkItemTypeType, null: false

    def resolve(name:, item_level:, quality_indicator_type:)
      work_item_type = WorkItemType.create(name: name, item_level: item_level, quality_indicator_type: quality_indicator_type)

      if work_item_type.valid?
        { status_message: 'SUCCESS', work_item_type: work_item_type }
      else
        { status_message: 'FAIL' }
      end
    end
  end
end
