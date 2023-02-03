# frozen_string_literal: true

module Types
  class UserType < Types::BaseObject
    field :admin, Boolean, null: false
    field :companies, [Types::CompaniesType], null: false
    field :current_company, CompanyType, null: true
    field :full_name, String, null: false
    field :id, ID, null: false
    field :language, String, null: false
    field :last_name, String, null: true

    field :avatar, Types::AvatarType, null: false

    def avatar
      { image_source: object.avatar.url }
    end

    def current_company
      object.last_company unless object.instance_of?(DeviseCustomer)
    end
  end
end
