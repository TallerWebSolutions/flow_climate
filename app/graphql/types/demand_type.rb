# frozen_string_literal: true

module Types
  class DemandType < Types::BaseObject
    field :id, ID, null: false
    field :external_id, String, null: false
    field :company, Types::CompanyType, null: false
    field :team, Types::TeamType, null: false
    field :project, Types::ProjectType, null: false
    field :demand_title, String, null: false
    field :leadtime, Float, null: true
    field :end_date, String, null: true

    field :number_of_blocks, Int, null: false
    field :product, Types::ProductType, null: true
    field :customer, Types::CustomerType, null: true

    def number_of_blocks
      object.demand_blocks.count
    end
  end
end
