# frozen_string_literal: true

module Types
  class InitiativeType < Types::BaseObject
    field :id, ID, null: false
    field :company, Types::CompanyType, null: false
    field :name, String, null: false
  end
end
