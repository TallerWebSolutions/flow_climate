# frozen_string_literal: true

module Types
  class DemandsListType < Types::BaseObject
    field :total_count, Int, null: false
    field :last_page, Boolean, null: false
    field :total_pages, Int, null: false

    field :demands, [Types::DemandType], null: false
  end
end
