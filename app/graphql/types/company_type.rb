# frozen_string_literal: true

module Types
  class CompanyType < Types::BaseObject
    field :id, ID, null: false
    field :initiatives, [Types::InitiativeType], null: false
    field :name, String, null: false
    field :projects, [Types::ProjectType], null: false
    field :slug, String, null: false
    field :teams, [Types::TeamType], null: false
  end
end
