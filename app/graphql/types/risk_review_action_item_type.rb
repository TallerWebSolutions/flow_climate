# frozen_string_literal: true

module Types
  class RiskReviewActionItemType < Types::BaseObject
    field :action_type, [String], null: false

    def action_type
      object.action_types
    end
  end
end
