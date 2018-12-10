# frozen_string_literal: true

Fabricator(:user_project_role) do
  id                   1
  user_id              1
  project_id           1
  user_role_in_project 1
  created_at           '2018-12-10 16:13:36'
  updated_at           '2018-12-10 16:13:36'
end
