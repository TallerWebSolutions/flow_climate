# frozen_string_literal: true

Fabricator(:user_company_role) do
  user
  company
  user_role 1
end
