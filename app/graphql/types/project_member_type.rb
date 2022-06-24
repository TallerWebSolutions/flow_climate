# frozen_string_literal: true

module Types
  class ProjectMemberType < Types::BaseObject
    field :demands_count, Int, null: false
    field :member_name, String, null: false
  end
end
