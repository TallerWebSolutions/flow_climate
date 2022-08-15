module Types
  module Charts
    class PieChartType < Types::BaseObject
      field :label, String, null: false
      field :value, Int, null: false
    end
  end
end
