# frozen_string_literal: true

module Types
  class CompanyType < Types::BaseObject
    field :id, ID, null: false
    field :name, String, null: false
    field :products, [Types::ProductType], null: false
    field :projects, [Types::ProjectType], null: false
    field :slug, String, null: false
    field :teams, [Types::Teams::TeamType], null: false
    field :work_item_types, [Types::WorkItemTypeType], null: true

    def work_item_types
      WorkItemType.where(company_id: object.id, item_level: 'demand')
    end

    def projects
      object.projects.order(:name)
    end

    def products
      object.products.order(:name)
    end
  end
end
