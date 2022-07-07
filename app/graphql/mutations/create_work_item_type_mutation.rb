# frozen_string_literal: true

module Mutations
  class CreateWorkItemTypeMutation < Mutations::BaseMutation
    argument :item_level, Types::Enums::WorkItemLevel, required: true
    argument :name, String, required: true
    argument :quality_indicator_type, Boolean, required: true

    field :work_item_type, Types::WorkItemTypeType, null: false

    def resolve(name:, item_level:, quality_indicator_type:)
      item_level_value = item_level == 'DEMAND' ? 0 : 1
      work_item_type = WorkItemType.create(company_id: current_user.last_company_id, name: name, item_level: item_level_value, quality_indicator_type: quality_indicator_type)

      { work_item_type: work_item_type }
    end
  end
end
