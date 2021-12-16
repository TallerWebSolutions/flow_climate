# frozen_string_literal: true

module Types
  class UserType < Types::BaseObject
    field :id, ID, null: false
    field :full_name, String, null: false

    field :avatar, Types::AvatarType, null: false

    def avatar
      { image_source: object.avatar.url }
    end
  end
end
