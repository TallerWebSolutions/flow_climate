# frozen_string_literal: true

module Types
  class ProjectType < Types::BaseObject
    field :id, ID, null: false
    field :name, String, null: false
    field :remaining_weeks, Int, null: false
    field :remaining_backlog, Int, null: false
    field :flow_pressure, Float, null: false
    field :flow_pressure_percentage, Float, null: false
    field :qty_selected, Int, null: false
    field :qty_in_progress, Int, null: false
    field :monte_carlo_p80, Float, null: false
    field :lead_time_p80, Float, null: false

    delegate :remaining_backlog, to: :object
    delegate :remaining_weeks, to: :object
    delegate :flow_pressure, to: :object
    delegate :monte_carlo_p80, to: :object

    def qty_in_progress
      object.in_wip.count
    end

    def flow_pressure_percentage
      object.relative_flow_pressure_in_replenishing_consolidation
    end

    def qty_selected
      object.qty_selected_in_week
    end

    def lead_time_p80
      object.general_leadtime
    end
  end
end
