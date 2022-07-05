# frozen_string_literal: true

Fabricator(:work_item_type) do
  company

  name { Faker::Name.first_name }
end
