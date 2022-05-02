# frozen_string_literal: true

module Types
  class ProjectMemberType < Types::BaseObject
    field :member_name, String, null: false
    field :demands_count, Int, null: false
  end
end
