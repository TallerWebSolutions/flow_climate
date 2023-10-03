module Types
    class DemandEffortsListType < BaseObject
        field :demand_efforts, [Types::DemandEffortType], null: true 
        field :demand_efforts_count, Int, null: true
    end
end