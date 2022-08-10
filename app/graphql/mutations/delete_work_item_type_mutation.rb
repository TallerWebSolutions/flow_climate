# frozen_string_literal: true

module Mutations
  class DeleteWorkItemTypeMutation < Mutations::BaseMutation
    argument :work_item_type_id, String, required: true

    field :status_message, Types::DeleteOperationResponses, null: false

    def resolve(work_item_type_id:)
      item_type = WorkItemType.find(work_item_type_id)

      if item_type.destroy
        { status_message: 'SUCCESS' }
      else
        { status_message: 'FAIL' }
      end
    end
  end
end
