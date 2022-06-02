module Types
  class DemandsQueryAttributes < Types::BaseInputObject
    description 'Attributes to query demands'

    argument :project_id, Int, required: false
    argument :limit, Int
    argument :sort_direction, Types::Enums::SortDirection, required: false

    argument :start_date, GraphQL::Types::ISO8601Date, required: false
    argument :end_date, GraphQL::Types::ISO8601Date, required: false
    argument :demand_status, Types::Enums::DemandStatusesType, required: false
    argument :demand_type, Types::Enums::DemandTypesType, required: false
    argument :demand_class_of_service, Types::Enums::DemandClassesOfServiceType, required: false
    argument :iniciative_id, Int, required: false
    argument :team_id, Int, required: false

    argument :search_text, String, required: false
    argument :demand_tags, String, required: false
  end
end
