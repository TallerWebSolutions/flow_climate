# frozen_string_literal: true

module Types
  class TeamType < Types::BaseObject
    field :average_throughput, Float, null: true
    field :company, Types::CompanyType, null: false
    field :cumulative_flow_chart_data, Types::Charts::CumulativeFlowChartType, null: true do
      argument :end_date, GraphQL::Types::ISO8601Date, required: false, description: 'End Date for the search range'
      argument :start_date, GraphQL::Types::ISO8601Date, required: false, description: 'Start Date for the search range'
    end
    field :end_date, GraphQL::Types::ISO8601Date, null: true
    field :id, ID, null: false
    field :increased_avg_throughtput, Boolean, null: true
    field :increased_leadtime_80, Boolean, null: true
    field :latest_deliveries, [Types::DemandType], null: true do
      argument :limit, Int, required: false
      argument :order_field, String, required: false
      argument :sort_direction, Types::Enums::SortDirection, required: false
      argument :start_date, GraphQL::Types::ISO8601Date, required: false, description: 'Start Date for the search range, will only bring demands finished after this date'
    end
    field :active_projects, [Types::ProjectType], null: true
    field :demands_flow_chart_data, Types::Charts::DemandsFlowChartDataType, null: true do
      argument :end_date, GraphQL::Types::ISO8601Date, required: false, description: 'End Date for the search range'
      argument :start_date, GraphQL::Types::ISO8601Date, required: false, description: 'Start Date for the search range'
    end
    field :last_replenishing_consolidations, [Types::ReplenishingConsolidationType], null: false
    field :lead_time, Float, null: true
    field :lead_time_histogram_data, Types::Charts::LeadTimeHistogramDataType, null: true do
      argument :end_date, GraphQL::Types::ISO8601Date, required: false, description: 'End Date for the search range'
      argument :start_date, GraphQL::Types::ISO8601Date, required: false, description: 'Start Date for the search range'
    end
    field :lead_time_p65, Float, null: true
    field :lead_time_p80, Float, null: true
    field :lead_time_p95, Float, null: true
    field :max_work_in_progress, Int, null: false
    field :name, String, null: false
    field :number_of_demands_delivered, Int, null: true
    field :projects, [Types::ProjectType], null: true
    field :start_date, GraphQL::Types::ISO8601Date, null: true
    field :team_consolidations_weekly, [Types::ProjectConsolidationType], null: true do
      argument :end_date, GraphQL::Types::ISO8601Date, required: false, description: 'End Date for the search range'
      argument :start_date, GraphQL::Types::ISO8601Date, required: false, description: 'Start Date for the search range'
    end
    field :team_monthly_investment, Types::MonthlyInvestmentType, null: true do
      argument :end_date, GraphQL::Types::ISO8601Date, required: false, description: 'End Date for the search range'
      argument :start_date, GraphQL::Types::ISO8601Date, required: false, description: 'Start Date for the search range'
    end
    field :hours_and_money_by_each_member, [Types::ValueEachMemberType], null: true
    field :team_capacity_hours, Int, null: true
    field :throughput_data, [Int], null: true
    field :work_in_progress, Int, null: true

    delegate :projects, to: :object

    def latest_deliveries(order_field: 'end_date', sort_direction: :desc, limit: 5, start_date: '')
      demands = object.demands.finished_until_date(Time.zone.now).where.not(leadtime: nil).limit(limit).order(order_field => sort_direction)
      demands = demands.where('end_date >= :limit_date', limit_date: start_date) if start_date.present?
      demands
    end

    def last_replenishing_consolidations
      team_active_projects = active_projects
      consolidations_ids = team_active_projects.map { |project| Consolidations::ReplenishingConsolidation.where(project: project).order(consolidation_date: :asc).last(1).map(&:id).flatten }

      Consolidations::ReplenishingConsolidation.where(id: consolidations_ids.flatten.compact)
    end

    def throughput_data
      last_replenishing_consolidations.last&.team_throughput_data
    end

    def average_throughput
      last_replenishing_consolidations.last&.average_team_throughput
    end

    def increased_avg_throughtput
      last_replenishing_consolidations.last&.increased_avg_throughtput?
    end

    def lead_time
      last_replenishing_consolidations.last&.team_lead_time
    end

    def lead_time_p65
      object.lead_time(object.start_date, object.end_date, 65)
    end

    def lead_time_p80
      object.lead_time(object.start_date, object.end_date, 80)
    end

    def lead_time_p95
      object.lead_time(object.start_date, object.end_date, 95)
    end

    def number_of_demands_delivered
      object.demands.kept.finished_until_date(Time.zone.now).count
    end

    def increased_leadtime_80
      last_replenishing_consolidations.last&.increased_leadtime_80?
    end

    def work_in_progress
      last_replenishing_consolidations.last&.team_wip
    end

    def active_projects
      projects.active
    end

    def cumulative_flow_chart_data(start_date: 6.months.ago, end_date: Time.zone.today)
      start_date = [object.start_date, start_date].max
      end_date = [object.end_date, end_date].min
      array_of_dates = TimeService.instance.weeks_between_of(start_date, end_date)
      work_item_flow_information = build_work_item_flow_information(array_of_dates)

      { x_axis: array_of_dates, y_axis: work_item_flow_information.demands_stages_count_hash }
    end

    def demands_flow_chart_data(start_date: 6.months.ago, end_date: Time.zone.today)
      start_date = [object.start_date, start_date].max
      end_date = [object.end_date, end_date].min
      Highchart::DemandsChartsAdapter.new(object.demands.kept, start_date, end_date, 'week')
    end

    def lead_time_histogram_data(start_date: 6.months.ago, end_date: Time.zone.today)
      demands = demands_finished_with_leadtime(start_date, end_date)
      Stats::StatisticsService.instance.leadtime_histogram_hash(demands.map(&:leadtime).map { |leadtime| leadtime.round(3) })
    end

    def team_consolidations_weekly(start_date: 6.months.ago, end_date: Time.zone.today)
      weekly_team_consolidations = object.team_consolidations.weekly_data.order(:consolidation_date)

      consolidations = Consolidations::TeamConsolidation
                       .where(id: weekly_team_consolidations.map(&:id) + [last_consolidation&.id])
      consolidations = consolidations.where('consolidation_date >= :limit_date', limit_date: start_date) if start_date.present?
      consolidations = consolidations.where('consolidation_date <= :limit_date', limit_date: end_date) if end_date.present?
      consolidations.order(:consolidation_date)
    end

    def team_monthly_investment(start_date: 6.months.ago, end_date: Time.zone.today)
      start_date = [object.start_date, start_date].max
      end_date = [object.end_date, end_date].min
      array_of_months = TimeService.instance.months_between_of(start_date, end_date)
      total_cost_per_week = []

      array_of_months.each do |date|
        total_cost_per_week.append(object.realized_money_in_month(date).round(2) - object.monthly_investment(date).round(2))
      end
      {
        x_axis: array_of_months,
        y_axis: total_cost_per_week
      }
    end

    def hours_and_money_by_each_member
      memberships = object.memberships.active.billable_member

      start_date = Time.zone.now.beginning_of_month
      end_date = Time.zone.now.end_of_month

      memberships.map do |membership|
        {
          membership: membership.member_name,
          effort_in_month: membership.effort_in_period(start_date, end_date),
          realized_money_in_month: membership.realized_money_in_period(start_date, end_date),
          member_capacity_value: membership[:hours_per_month]
        }
      end
    end

    def team_capacity_hours
      memberships = object.memberships.active.billable_member

      capacity_value = 0
      memberships.each do |membership|
        capacity_value += membership[:hours_per_month]
      end
      capacity_value
    end

    private

    def build_work_item_flow_information(array_of_dates)
      work_item_flow_information = Flow::WorkItemFlowInformation.new(object.demands, object.initial_scope, array_of_dates.length, array_of_dates.last, 'week')
      array_of_dates.each { |analysed_date| work_item_flow_information.build_cfd_hash(array_of_dates.first.beginning_of_week, analysed_date) }
      work_item_flow_information
    end

    def demands_finished_with_leadtime(start_date, end_date)
      demands = object.demands.finished_with_leadtime
      demands = demands.finished_after_date(start_date) if start_date.present?
      demands = demands.finished_until_date(end_date) if end_date.present?
      demands
    end

    def last_consolidation
      @last_consolidation ||= object.team_consolidations.order(:consolidation_date).last
    end
  end
end
