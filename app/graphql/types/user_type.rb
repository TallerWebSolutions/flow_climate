# frozen_string_literal: true

module Types
  class UserType < Types::BaseObject
    field :id, ID, null: false
    field :full_name, String, null: false
    field :language, String, null: false
    field :current_company, CompanyType, null: true
    field :companies, [Types::CompaniesType], null: false
    field :admin, Boolean, null: false

    field :avatar, Types::AvatarType, null: false

    def avatar
      { image_source: object.avatar.url }
    end

    def current_company
      object.last_company
    end
  end
end
