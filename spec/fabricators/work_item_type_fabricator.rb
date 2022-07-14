# frozen_string_literal: true

Fabricator(:work_item_type) do
  company

  name { Faker::Name.first_name }

  item_level { WorkItemType.item_levels.keys.sample }
end
