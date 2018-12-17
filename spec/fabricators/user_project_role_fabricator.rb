# frozen_string_literal: true

Fabricator(:user_project_role) do
  user
  project
  role_in_project 1
end
