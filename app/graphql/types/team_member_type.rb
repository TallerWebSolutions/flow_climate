# frozen_string_literal: true

module Types
  class TeamMemberType < Types::BaseObject
    field :id, ID, null: false
    field :name, String, null: false
    field :jira_account_id, String, null: true
    field :jira_account_user_email, String, null: true
    field :start_date, GraphQL::Types::ISO8601Date, null: true
    field :end_date, GraphQL::Types::ISO8601Date, null: true
    field :billable, Boolean, null: false
    field :hours_per_month, Int, null: false
    field :monthly_payment, Float, null: true
    field :teams, [Types::TeamType], null: true

    field :demands, [Types::DemandType] do
      argument :status, Types::Enums::DemandStatusesType, required: false
      argument :type, Types::Enums::DemandTypesType, required: false
      argument :limit, Int, required: false
    end

    field :projects, [Types::ProjectType]

    field :demand_shortest_lead_time, Types::DemandType, null: true
    field :demand_largest_lead_time, Types::DemandType, null: true
    field :first_demand_delivery, Types::DemandType, null: true

    field :demand_lead_time_p80, Float, null: true
    field :first_delivery, Types::DemandType, null: true

    field :demand_blocks, [Types::DemandBlockType], null: true

    field :lead_time_control_chart_data, Types::Charts::LeadTimeControlChartDataType, null: true

    def demands(status: 'ALL', type: 'ALL', limit: nil)
      demands = if status == 'FINISHED'
                  object.demands.finished_until_date(Time.zone.now).order(end_date: :desc)
                else
                  object.demands.order(:created_date)
                end

      demands = demands.bug.order(:created_date) if type == 'BUG'

      return demands if limit.blank?

      demands.limit(limit)
    end

    def demand_shortest_lead_time
      object.demands.finished_with_leadtime.order(:leadtime).first
    end

    def demand_largest_lead_time
      object.demands.finished_with_leadtime.order(:leadtime).last
    end

    def demand_lead_time_p80
      Stats::StatisticsService.instance.percentile(80, object.demands.finished_with_leadtime.map(&:leadtime))
    end

    def demand_blocks
      object.demand_blocks.order(:block_time)
    end

    def lead_time_control_chart_data
      LeadTimeControlChartData.new(object.demands.finished_until_date(Time.zone.now))
    end
  end
end
