# frozen_string_literal: true

module Types
  module Teams
    class TeamMemberType < Types::BaseObject
      field :billable, Boolean, null: false
      field :demand_efforts, [Types::DemandEffortType], null: true do
        argument :from_date, GraphQL::Types::ISO8601Date, required: false
        argument :page_number, Integer, required: false
        argument :until_date, GraphQL::Types::ISO8601Date, required: false
      end
      field :demand_efforts_list, Types::DemandEffortsListType, null: true do
        argument :from_date, GraphQL::Types::ISO8601Date, required: false
        argument :page_number, Integer, required: false
        argument :until_date, GraphQL::Types::ISO8601Date, required: false
      end
      field :end_date, GraphQL::Types::ISO8601Date, null: true
      field :hours_per_month, Int, null: false
      field :id, ID, null: false
      field :jira_account_id, String, null: true
      field :jira_account_user_email, String, null: true
      field :monthly_payment, Float, null: true
      field :name, String, null: false
      field :start_date, GraphQL::Types::ISO8601Date, null: true
      field :teams, [Types::Teams::TeamType], null: true
      field :user, Types::UserType, null: true

      field :demands, [Types::DemandType] do
        argument :limit, Int, required: false
        argument :status, Types::Enums::DemandStatusesType, required: false
        argument :type, String, required: false
      end

      field :projects_list, Types::ProjectsListType, null: true do
        argument :order_field, String, required: true
        argument :page_number, Int, required: false
        argument :per_page, Int, required: false
        argument :sort_direction, Types::Enums::SortDirection, required: false
      end

      field :demand_largest_lead_time, Types::DemandType, null: true
      field :demand_shortest_lead_time, Types::DemandType, null: true
      field :first_demand_delivery, Types::DemandType, null: true

      field :demand_lead_time_p80, Float, null: true
      field :first_delivery, Types::DemandType, null: true

      field :demand_blocks_list, Types::DemandBlocksListType, null: true do
        argument :order_field, String, required: true
        argument :page_number, Int, required: false
        argument :per_page, Int, required: false
        argument :sort_direction, Types::Enums::SortDirection, required: false
      end

      field :team_member_consolidation_list, [Types::TeamMemberConsolidationType], null: true

      field :average_pull_interval_data, Types::Charts::SimpleDateChartDataType, null: true
      field :lead_time_control_chart_data, Types::Charts::ControlChartType, null: true
      field :lead_time_histogram_chart_data, Types::Charts::LeadTimeHistogramDataType, null: true
      field :member_effort_daily_data, Types::Charts::SimpleDateChartDataType, null: true
      field :member_effort_data, Types::Charts::SimpleDateChartDataType, null: true

      field :member_throughput_data, [Int], null: true do
        argument :number_of_weeks, Int, required: false
      end

      field :project_hours_data, Types::Charts::ProjectHoursChartDataType, null: true

      def demand_efforts(from_date: nil, until_date: nil, page_number: nil)
        efforts = object.demand_efforts.to_dates(from_date, until_date).order(start_time_to_computation: :desc)
        efforts.page(page_number).per(20)
      end

      def demands(status: 'ALL', type: 'ALL', limit: nil)
        demands = if status == 'DELIVERED_DEMANDS'
                    object.demands.finished_until_date(Time.zone.now).order(end_date: :desc)
                  else
                    object.demands.order(:created_date)
                  end

        demands = demands.bug.order(:created_date) if type == 'BUG'

        return demands if limit.blank?

        demands.limit(limit)
      end

      # TODO: Fix logic
      def team_member_consolidation_list
        membership = object
        members_value_per_hour = []
        (1..13).reverse_each { |month| members_value_per_hour << build_member_value_per_hour(month, membership) }

        members_value_per_hour
      end

      def demand_efforts_list(from_date: nil, until_date: nil, page_number: nil)
        efforts = object.demand_efforts.to_dates(from_date, until_date).order(start_time_to_computation: :desc)
        efforts_paginated = efforts.page(page_number).per(10)
        { 'demand_efforts_count' => efforts.count, 'demand_efforts' => efforts_paginated, 'efforts_value_sum' => efforts.sum(&:effort_value).round(2) }
      end

      def projects_list(order_field:, sort_direction: 'ASC', per_page: 10, page_number: 1)
        projects = if sort_direction == 'DESC'
                     object.projects.order("#{order_field} DESC")
                   else
                     object.projects.order(order_field)
                   end

        projects_page = projects.page(page_number).per(per_page)
        ProjectsList.new(projects_page, projects.count, projects_page.last_page?, projects_page.total_pages)
      end

      def demand_blocks_list(order_field:, sort_direction: 'ASC', per_page: 10, page_number: 1)
        demand_blocks = if sort_direction == 'DESC'
                          object.demand_blocks.order("#{order_field} DESC")
                        else
                          object.demand_blocks.order(order_field)
                        end

        demand_blocks_page = demand_blocks.page(page_number).per(per_page)
        DemandBlocksList.new(demand_blocks_page, demand_blocks.count, demand_blocks_page.last_page?, demand_blocks_page.total_pages)
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

      def lead_time_control_chart_data
        LeadTimeControlChartData.new(object.demands.finished_until_date(Time.zone.now))
      end

      def lead_time_histogram_chart_data
        demands_finished = object.demands.finished_with_leadtime
        Stats::StatisticsService.instance.leadtime_histogram_hash(demands_finished.map(&:leadtime).map { |leadtime| leadtime.round(3) })
      end

      def member_effort_data
        accumulator = first_day_of_six_months_hash
        object
          .demand_efforts.select("sum(effort_value) as effort_value_sum, date_trunc('month', start_time_to_computation) as month")
          .where('start_time_to_computation >= TIMESTAMP WITH TIME ZONE :date', date: member_effort_data_interval.iso8601)
          .group('month').each do |item|
          accumulator[item.month.to_date.to_s] += item.effort_value_sum.round(2)
        end
        { x_axis: accumulator.keys, y_axis: accumulator.values }
      end

      def member_effort_daily_data
        accumulator = last_30_days_hash
        object.demand_efforts.where('start_time_to_computation >= TIMESTAMP WITH TIME ZONE :date', date: member_effort_daily_interval.iso8601).find_each do |effort|
          accumulator[effort.start_time_to_computation.beginning_of_day.to_date.to_s] += effort.effort_value.round(2)
        end
        { x_axis: accumulator.keys, y_axis: accumulator.values }
      end

      def average_pull_interval_data
        { x_axis: operations_dashboards.map { |dash| dash.dashboard_date.iso8601 }, y_axis: operations_dashboards.map(&:pull_interval) }
      end

      def member_throughput_data(number_of_weeks: 52)
        DemandService.instance.build_throughput_per_period_array(object.demands.finished_until_date(Time.zone.now), number_of_weeks.week.ago.beginning_of_week, Time.zone.now)
      end

      def project_hours_data
        team_chart_adapter = Highchart::TeamMemberAdapter.new(object)
        { x_axis: team_chart_adapter.x_axis_hours_per_project, y_axis_projects_names: team_chart_adapter.y_axis_hours_per_project.pluck(:name), y_axis_hours: team_chart_adapter.y_axis_hours_per_project.pluck(:data).flatten }
      end

      private

      # TODO: Fix Logic
      def build_member_value_per_hour(month, membership)
        { 'consolidation_date' => month.month.ago.beginning_of_month, 'hour_value_realized' => compute_hours_per_month(membership.monthly_payment, membership.demand_efforts.to_dates(month.month.ago.beginning_of_month, month.month.ago.end_of_month).sum(&:effort_value).to_f) }
      end

      def operations_dashboards
        @operations_dashboards ||= Dashboards::OperationsDashboard.where(
          team_member: object,
          last_data_in_month: true
        ).where('operations_dashboards.dashboard_date > :limit_date', limit_date: 6.months.ago.beginning_of_day).order(:dashboard_date)
      end

      def member_effort_data_interval = 6.months.ago.at_beginning_of_month.beginning_of_day
      def member_effort_daily_interval = 30.days.ago.beginning_of_day

      def first_day_of_six_months_hash
        accumulator = Hash.new { |hash, key| hash[key] = 0 }
        range = (member_effort_data_interval.to_date..Time.zone.now.at_beginning_of_month.beginning_of_day)
        range.select { |date| date.day == 1 }.each do |day|
          accumulator[day.to_s] = 0
        end
        accumulator
      end

      def last_30_days_hash
        accumulator = Hash.new { |hash, key| hash[key] = 0 }
        (member_effort_daily_interval.to_date..Time.zone.now).each do |day|
          accumulator[day.to_s] = 0
        end
        accumulator
      end

      def compute_hours_per_month(monthly_payment, monthly_hours)
        return monthly_payment if monthly_hours.zero?

        monthly_payment / monthly_hours
      end
    end
  end
end
