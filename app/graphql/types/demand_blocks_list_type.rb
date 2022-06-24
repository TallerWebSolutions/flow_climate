# frozen_string_literal: true

module Types
  class DemandBlocksListType < Types::BaseObject
    field :last_page, Boolean, null: false
    field :total_count, Int, null: false
    field :total_pages, Int, null: false

    field :demand_blocks, [Types::DemandBlockType], null: false
  end
end
