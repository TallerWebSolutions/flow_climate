# frozen_string_literal: true

module Types
  class TeamMemberType < Types::BaseObject
    field :billable, Boolean, null: false
    field :end_date, GraphQL::Types::ISO8601Date, null: true
    field :hours_per_month, Int, null: false
    field :id, ID, null: false
    field :jira_account_id, String, null: true
    field :jira_account_user_email, String, null: true
    field :monthly_payment, Float, null: true
    field :name, String, null: false
    field :start_date, GraphQL::Types::ISO8601Date, null: true
    field :teams, [Types::TeamType], null: true
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

    field :average_pull_interval_data, Types::Charts::SimpleDateChartDataType, null: true
    field :lead_time_control_chart_data, Types::Charts::ControlChartType, null: true
    field :lead_time_histogram_chart_data, Types::Charts::LeadTimeHistogramDataType, null: true
    field :member_effort_daily_data, Types::Charts::SimpleDateChartDataType, null: true
    field :member_effort_data, Types::Charts::SimpleDateChartDataType, null: true
    field :member_throughput_data, [Int], null: true do
      argument :number_of_weeks, Int, required: false
    end
    field :project_hours_data, Types::Charts::ProjectHoursChartDataType, null: true

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
      { x_axis: operations_dashboards.map(&:dashboard_date).map(&:iso8601), y_axis: operations_dashboards.map { |dashboard| dashboard.member_effort.to_f } }
    end

    def member_effort_daily_data
      accumulator = last_30_days_hash
      object.demand_efforts.where('start_time_to_computation >= TIMESTAMP WITH TIME ZONE :date', date: 30.days.ago.beginning_of_day.iso8601).each do |effort|
        accumulator[effort.start_time_to_computation.beginning_of_day.to_date.to_s] += effort.effort_value.round(2)
      end
      { x_axis: accumulator.keys, y_axis: accumulator.values }
    end

    def average_pull_interval_data
      { x_axis: operations_dashboards.map(&:dashboard_date).map(&:iso8601), y_axis: operations_dashboards.map(&:pull_interval) }
    end

    def member_throughput_data(number_of_weeks: 52)
      DemandService.instance.build_throughput_per_period_array(object.demands.finished_until_date(Time.zone.now), number_of_weeks.week.ago.beginning_of_week, Time.zone.now)
    end

    def project_hours_data
      team_chart_adapter = Highchart::TeamMemberAdapter.new(object)
      { x_axis: team_chart_adapter.x_axis_hours_per_project, y_axis_projects_names: team_chart_adapter.y_axis_hours_per_project.pluck(:name), y_axis_hours: team_chart_adapter.y_axis_hours_per_project.pluck(:data).flatten }
    end

    private

    def operations_dashboards
      @operations_dashboards ||= Dashboards::OperationsDashboard
                                 .where(
                                   team_member: object,
                                   last_data_in_month: true
                                 )
                                 .where('operations_dashboards.dashboard_date > :limit_date', limit_date: 6.months.ago.beginning_of_day)
                                 .order(:dashboard_date)
    end

    def last_30_days_hash
      accumulator = Hash.new { |hash, key| hash[key] = 0 }
      (30.days.ago.beginning_of_day.to_date..Time.zone.now).each { |day| accumulator[day.to_s] = 0 }
      accumulator
    end
  end
end
