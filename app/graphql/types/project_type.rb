# frozen_string_literal: true

module Types
  class ProjectType < Types::BaseObject
    field :aging, Int, null: false
    field :average_demand_aging, Float, null: true
    field :average_queue_time, Float, null: true
    field :average_speed, Float, null: true
    field :average_touch_time, Float, null: true
    field :backlog_count_for, Int, null: true
    field :company, Types::CompanyType, null: false
    field :consumed_active_contracts_hours, Int, null: false
    field :consumed_hours, Float, null: false
    field :cumulative_flow_chart_data, Types::Charts::CumulativeFlowChartType, null: true
    field :current_cost, Float, null: true
    field :current_monte_carlo_weeks_max, Int, null: true
    field :current_monte_carlo_weeks_min, Int, null: true
    field :current_monte_carlo_weeks_std_dev, Int, null: true
    field :current_risk_to_deadline, Float, null: true
    field :current_team_based_risk, Float, null: true
    field :current_weeks_by_little_law, Int, null: true
    field :customers, [Types::CustomerType], null: true
    field :customers_names, String, null: true
    field :days_difference_between_first_and_last_deadlines, Int, null: true
    field :deadlines_change_count, Int, null: true
    field :demand_blocks, [Types::DemandType], null: true
    field :demands_burnup, Types::Charts::BurnupType, null: true
    field :demands_finished_with_leadtime, [Types::DemandType], null: true
    field :demands_flow_chart_data, Types::Charts::DemandsFlowChartDataType, null: true
    field :discarded_demands, [Types::DemandType], null: true
    field :discovered_scope, Int, null: true
    field :end_date, GraphQL::Types::ISO8601Date, null: true
    field :failure_load, Float, null: true
    field :first_deadline, GraphQL::Types::ISO8601Date, null: true
    field :flow_pressure, Float, null: false
    field :flow_pressure_percentage, Float, null: false
    field :general_leadtime, Float, null: true
    field :hours_burnup, Types::Charts::BurnupType, null: true
    field :hours_per_stage_chart_data, Types::Charts::HoursPerStageChartType, null: true do
      argument :stage_level, String, required: false
    end
    field :id, ID, null: false
    field :initial_scope, Int, null: false
    field :last_project_consolidations_weekly, Types::ProjectConsolidationType, null: true
    field :lead_time_breakdown, Types::Charts::LeadTimeBreakdownType, null: true
    field :lead_time_histogram_data, Types::Charts::LeadTimeHistogramDataType, null: true
    field :lead_time_p65, Float, null: false
    field :lead_time_p80, Float, null: false
    field :lead_time_p95, Float, null: false
    field :max_work_in_progress, Int, null: false
    field :mode_weekly_troughputs, Int, null: false
    field :monte_carlo_p80, Float, null: false
    field :name, String, null: false
    field :number_of_demands, Int, null: true
    field :number_of_demands_delivered, Int, null: true
    field :number_of_downstream_demands, Int, null: true
    field :past_weeks, Int, null: false
    field :percentage_expedite, Float, null: true
    field :percentage_fixed_date, Float, null: true
    field :percentage_hours_delivered, Float, null: false
    field :percentage_remaining_work, Float, null: true
    field :percentage_standard, Float, null: true
    field :products, [Types::ProductType], null: true
    field :project_consolidations, [Types::ProjectConsolidationType], null: true
    field :project_consolidations_last_month, [Types::ProjectConsolidationType], null: true
    field :project_consolidations_weekly, [Types::ProjectConsolidationType], null: true
    field :project_members, [Types::ProjectMemberType], null: true
    field :project_simulation, Types::ProjectSimulationType, null: true do
      argument :end_date, GraphQL::Types::ISO8601Date, required: true
      argument :remaining_work, Int, required: true
      argument :throughputs, [Int], required: true
    end
    field :project_weeks, [GraphQL::Types::ISO8601Date], null: true
    field :qty_hours, Float, null: false
    field :qty_in_progress, Int, null: false
    field :qty_selected, Int, null: false
    field :quality, Float, null: true
    field :remaining_active_contracts_hours, Int, null: false
    field :remaining_backlog, Int, null: false
    field :remaining_days, Int, null: true
    field :remaining_weeks, Int, null: false
    field :remaining_work, Int, null: false
    field :running, Boolean, null: true
    field :start_date, GraphQL::Types::ISO8601Date, null: false
    field :status, String, null: false
    field :std_dev_weekly_troughputs, Float, null: false
    field :team, Types::Teams::TeamType, null: false
    field :team_based_odds_to_deadline, Float, null: false
    field :team_monte_carlo_p80, Float, null: false
    field :team_monte_carlo_weeks_max, Float, null: false
    field :team_monte_carlo_weeks_min, Float, null: false
    field :team_monte_carlo_weeks_std_dev, Float, null: false
    field :total_active_contracts_hours, Int, null: false
    field :total_scope, Int, null: false
    field :total_throughput, Int, null: true
    field :unscored_demands, [Types::DemandType], null: true
    field :upstream_demands, [Types::DemandType], null: true
    field :value, Float, null: true
    field :weekly_throughputs, [Int], null: false

    delegate :remaining_backlog, to: :object
    delegate :remaining_weeks, to: :object
    delegate :flow_pressure, to: :object
    delegate :monte_carlo_p80, to: :object
    delegate :team_monte_carlo_p80, to: :object
    delegate :team_monte_carlo_weeks_max, to: :object
    delegate :team_monte_carlo_weeks_min, to: :object
    delegate :team_based_odds_to_deadline, to: :object

    def unscored_demands
      object.demands.kept.unscored_demands
    end

    def project_simulation(remaining_work:, throughputs:, end_date:)
      project_based_montecarlo_durations = Stats::StatisticsService.instance.run_montecarlo(remaining_work, throughputs, 500)
      team_based_montecarlo_durations = compute_team_monte_carlo_weeks(remaining_work, throughputs)

      operational_risk, team_operational_risk = operational_risk_info(end_date, project_based_montecarlo_durations, team_based_montecarlo_durations)

      {
        operational_risk: operational_risk,
        team_operational_risk: team_operational_risk,

        monte_carlo_p80: Stats::StatisticsService.instance.percentile(80, project_based_montecarlo_durations),
        current_monte_carlo_weeks_max: project_based_montecarlo_durations.max,
        current_monte_carlo_weeks_min: project_based_montecarlo_durations.min,
        current_monte_carlo_weeks_std_dev: Stats::StatisticsService.instance.standard_deviation(project_based_montecarlo_durations),

        team_monte_carlo_p80: Stats::StatisticsService.instance.percentile(80, team_based_montecarlo_durations),
        team_monte_carlo_weeks_max: team_based_montecarlo_durations.max,
        team_monte_carlo_weeks_min: team_based_montecarlo_durations.min,
        team_monte_carlo_weeks_std_dev: Stats::StatisticsService.instance.standard_deviation(team_based_montecarlo_durations)
      }
    end

    def discarded_demands
      object.demands.discarded
    end

    def demands_finished_with_leadtime
      object.demands.finished_with_leadtime
    end

    def number_of_downstream_demands
      object.demands.kept.in_wip(Time.zone.now).count
    end

    def number_of_demands
      object.demands.count
    end

    def number_of_demands_delivered
      object.demands.kept.finished_until_date(Time.zone.now).count
    end

    def running
      object.running?
    end

    def qty_in_progress
      object.in_wip.count
    end

    def flow_pressure_percentage
      object.relative_flow_pressure_in_replenishing_consolidation
    end

    def qty_selected
      object.qty_selected_in_week
    end

    def lead_time_p65
      object.general_leadtime(65)
    end

    def lead_time_p80
      object.general_leadtime
    end

    def lead_time_p95
      object.general_leadtime(95)
    end

    def weekly_throughputs
      object.last_weekly_throughput
    end

    def mode_weekly_troughputs
      Stats::StatisticsService.instance.mode(weekly_throughputs) || 0
    end

    def std_dev_weekly_troughputs
      Stats::StatisticsService.instance.standard_deviation(weekly_throughputs)
    end

    def deadlines_change_count
      object.project_change_deadline_histories.count
    end

    def discovered_scope
      project_summary = ProjectsSummaryData.new([object])
      project_summary.discovered_scope['discovered_after']
    end

    def current_monte_carlo_weeks_min
      return 0 if last_consolidation.blank?

      last_consolidation.monte_carlo_weeks_min
    end

    def current_monte_carlo_weeks_max
      return 0 if last_consolidation.blank?

      last_consolidation.monte_carlo_weeks_max
    end

    def current_monte_carlo_weeks_std_dev
      return 0 if last_consolidation.blank?

      last_consolidation.monte_carlo_weeks_std_dev
    end

    def current_weeks_by_little_law
      return 0 if last_consolidation.blank?

      last_consolidation.weeks_by_little_law
    end

    def current_team_based_risk
      return 0 if last_consolidation.blank?

      last_consolidation.team_based_operational_risk
    end

    def project_consolidations_weekly
      weekly_project_consolidations = object.project_consolidations.weekly_data.order(:consolidation_date)
      Consolidations::ProjectConsolidation.where(id: weekly_project_consolidations.map(&:id) + [last_consolidation&.id]).order(:consolidation_date)
    end

    def project_consolidations_last_month
      object.project_consolidations.order(:consolidation_date).select(&:last_data_for_month?)
    end

    def last_project_consolidations_weekly
      object.project_consolidations.order(:consolidation_date).weekly_data.last
    end

    def hours_per_stage_chart_data(stage_level: 'team')
      start_date = object.start_date
      hours_per_stage = StagesRepository.instance.hours_per_stage([object], :downstream, stage_level, start_date)
      { x_axis: hours_per_stage.to_h.keys, y_axis: { name: I18n.t('general.hours'), data: hours_per_stage.to_h.values.map { |hours| hours.to_f / 1.hour } } }
    end

    def cumulative_flow_chart_data
      start_date = object.start_date
      end_date = [object.end_date, Time.zone.today].min
      array_of_dates = TimeService.instance.weeks_between_of(start_date, end_date)
      work_item_flow_information = build_work_item_flow_information(array_of_dates)

      { x_axis: array_of_dates, y_axis: work_item_flow_information.demands_stages_count_hash }
    end

    def demands_flow_chart_data
      start_date = object.start_date
      end_date = [object.end_date, Time.zone.today].min
      Highchart::DemandsChartsAdapter.new(object.demands.kept, start_date, end_date, 'week')
    end

    def lead_time_histogram_data
      Stats::StatisticsService.instance.leadtime_histogram_hash(demands_finished_with_leadtime.map(&:leadtime).map { |leadtime| leadtime.round(3) })
    end

    def project_members
      team_members = object.team_members
      finished_demands = object.demands.finished_until_date(Time.zone.now)

      project_members_list = []

      team_members.each do |member|
        member_demands_count = finished_demands.for_team_member(member).count
        project_member = ProjectMember.new(member, member_demands_count)
        project_members_list << project_member
      end

      project_members_list
    end

    def demands_burnup
      consolidations = weekly_consolidations

      th = consolidations.map(&:project_throughput)

      { x_axis: project_weeks, current_burn: th, ideal_burn: object.current_weekly_scope_ideal_burnup, scope: object.weekly_project_scope_until_end }
    end

    def hours_burnup
      hours_th = weekly_consolidations.map(&:project_throughput_hours)
      { x_axis: project_weeks, ideal_burn: object.current_weekly_hours_ideal_burnup, scope: object.weekly_project_scope_hours_until_end, current_burn: hours_th }
    end

    def project_weeks
      TimeService.instance.weeks_between_of(object.start_date.beginning_of_week, object.end_date.end_of_week)
    end

    def lead_time_breakdown
      breakdown_stages = object.lead_time_breakdown.keys
      breakdown_values = object.lead_time_breakdown.values.map { |transitions| (transitions.sum(&:total_seconds_in_transition) / 1.hour) }
      { x_axis: breakdown_stages, y_axis: breakdown_values }
    end

    private

    def operational_risk_info(end_date, project_based_montecarlo_durations, team_based_montecarlo_durations)
      remaining_weeks = ((end_date - Time.zone.today) / 7).ceil
      operational_risk = 1 - Stats::StatisticsService.instance.compute_odds_to_deadline(remaining_weeks, project_based_montecarlo_durations)
      team_operational_risk = 1 - Stats::StatisticsService.instance.compute_odds_to_deadline(remaining_weeks, team_based_montecarlo_durations)

      [operational_risk, team_operational_risk]
    end

    def compute_team_monte_carlo_weeks(remaining_work, throughputs)
      team = object.team

      project_wip = [object.max_work_in_progress, 1].max
      team_wip = [team.max_work_in_progress, 1].max || 1
      project_share_in_team_flow = project_wip.to_f / team_wip

      project_share_team_throughput_data = throughputs.map { |throughput| throughput * project_share_in_team_flow }
      Stats::StatisticsService.instance.run_montecarlo(remaining_work, project_share_team_throughput_data, 500)
    end

    def weekly_consolidations
      weekly_consolidations_ids = object.project_consolidations.weekly_data.order(:consolidation_date).map(&:id)
      last_consolidation_id = [object.project_consolidations.order(:consolidation_date).last&.id]
      Consolidations::ProjectConsolidation.where(id: [weekly_consolidations_ids + last_consolidation_id].flatten.uniq)
    end

    def build_work_item_flow_information(array_of_dates)
      work_item_flow_information = Flow::WorkItemFlowInformation.new(object.demands, object.initial_scope, array_of_dates.length, array_of_dates.last, 'week')
      array_of_dates.each { |analysed_date| work_item_flow_information.build_cfd_hash(array_of_dates.first.beginning_of_week, analysed_date) }
      work_item_flow_information
    end

    def last_consolidation
      @last_consolidation ||= object.project_consolidations.order(:consolidation_date).last
    end
  end
end
