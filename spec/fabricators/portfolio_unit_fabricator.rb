# frozen_string_literal: true

Fabricator :portfolio_unit do
  product
  name { Faker::Company.name }
  portfolio_unit_type { %i[product_module key_result impact].sample }
end
