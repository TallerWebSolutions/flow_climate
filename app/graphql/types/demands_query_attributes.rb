# frozen_string_literal: true

module Types
  class DemandsQueryAttributes < Types::BaseInputObject
    description 'Attributes to query demands'

    argument :project_id, ID, required: false

    argument :order_field, String, required: true
    argument :sort_direction, Types::Enums::SortDirection, required: false
    argument :per_page, Int, required: false
    argument :page_number, Int, required: false

    argument :start_date, GraphQL::Types::ISO8601Date, required: false
    argument :end_date, GraphQL::Types::ISO8601Date, required: false
    argument :demand_status, Types::Enums::DemandStatusesType, required: false
    argument :demand_type, Types::Enums::DemandTypesType, required: false
    argument :demand_class_of_service, Types::Enums::DemandClassesOfServiceType, required: false
    argument :iniciative_id, ID, required: false
    argument :team_id, ID, required: false

    argument :search_text, String, required: false
    argument :demand_tags, String, required: false
  end
end
