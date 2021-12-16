# frozen_string_literal: true

module Types
  class AvatarType < Types::BaseObject
    field :image_source, String, null: false

    def image_source
      current_user.avatar.url
    end
  end
end
