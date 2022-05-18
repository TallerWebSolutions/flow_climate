# frozen_string_literal: true

module Types
  class ProjectsListType < Types::BaseObject
    field :total_count, Int, null: false
    field :last_page, Boolean, null: false
    field :total_pages, Int, null: false

    field :projects, [Types::ProjectType], null: false
  end
end
