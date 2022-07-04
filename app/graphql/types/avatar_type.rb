# frozen_string_literal: true

module Types
  class AvatarType < Types::BaseObject
    field :image_source, String, null: true
  end
end
