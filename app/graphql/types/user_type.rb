# frozen_string_literal: true

module Types
  class UserType < Types::BaseObject
    field :admin, Boolean, null: false
    field :avatar, Types::AvatarType, null: false
    field :companies, [Types::CompaniesType], null: false
    field :current_company, CompanyType, null: true
    field :first_name, String, null: true
    field :full_name, String, null: false
    field :id, ID, null: false
    field :language, String, null: false
    field :last_name, String, null: true
    field :products, [Types::ProductType], null: true
    field :projects, [Types::ProjectType], null: true do
      argument :name, String, required: false
    end
    field :projects_active, [Types::ProjectType], null: true
    field :user_is_manager, Boolean, null: false, method: :manager?

    def projects(name: nil)
      projects = object.projects.active
      projects = object.projects.where('projects.name ILIKE :name_search', name_search: "%#{name}%") if name.present?
      projects.order(:name)
    end

    def projects_active
      object.projects.active.order(:name)
    end

    def avatar
      { image_source: object.avatar.url }
    end

    def current_company
      object.last_company unless object.instance_of?(DeviseCustomer)
    end
  end
end
