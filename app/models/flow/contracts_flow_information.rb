# frozen_string_literal: true

module Flow
  class ContractsFlowInformation < SystemFlowInformation
    attr_reader :dates_array, :dates_limit_now_array, :contract, :limit_date, :consumed_hours,
                :financial_ideal, :financial_current, :financial_ideal_slice, :financial_total, :total_financial_value,
                :hours_ideal, :hours_current, :hours_ideal_slice, :hours_total, :total_hours_value, :remaining_hours,
                :scope_ideal, :scope_current, :scope_ideal_slice, :scope_total, :total_scope_value, :delivered_demands_count, :remaining_backlog_count,
                :quality_info, :quality_info_month, :lead_time_info, :throughput_info, :hours_blocked_per_deliver_info,
                :effort_info, :effort_info_month

    def initialize(contract, data_interval = 'month')
      @contract = contract
      super(contract.demands)

      @financial_burnup = {}

      build_dates_array(data_interval)
      build_dates_limit_now_array(data_interval)
      build_limit_date(data_interval)
      build_arrays

      build_hours_finances_constants
      build_scope_constants
      build_operations_charts_info(@contract.hour_value)
    end

    def build_financial_burnup
      return blank_burnup if @demands.blank?

      [{ name: I18n.t('charts.burnup.scope'), data: @financial_total }, { name: I18n.t('charts.burnup.current'), data: @financial_current }, { name: I18n.t('charts.burnup.ideal'), data: @financial_ideal }]
    end

    def build_hours_burnup
      return blank_burnup if @demands.blank?

      [{ name: I18n.t('charts.burnup.scope'), data: @hours_total }, { name: I18n.t('charts.burnup.current'), data: @hours_current }, { name: I18n.t('charts.burnup.ideal'), data: @hours_ideal }]
    end

    def build_scope_burnup
      return blank_burnup if @demands.blank?

      [{ name: I18n.t('charts.burnup.scope'), data: @scope_total }, { name: I18n.t('charts.burnup.current'), data: @scope_current }, { name: I18n.t('charts.burnup.ideal'), data: @scope_ideal }]
    end

    def build_quality_info
      return [{ name: I18n.t('charts.quality_info.bugs_by_delivery'), data: [] }, { name: I18n.t('charts.quality_info.bugs_by_delivery_month'), data: [] }] if @demands.blank?

      [{ name: I18n.t('charts.quality_info.bugs_by_delivery'), data: @quality_info }, { name: I18n.t('charts.quality_info.bugs_by_delivery_month'), data: @quality_info_month }]
    end

    def build_lead_time_info
      return [{ name: I18n.t('general.leadtime_p80_label'), data: [] }, { name: I18n.t('general.dashboards.lead_time_in_month'), data: [] }] if @demands.blank?

      [{ name: I18n.t('general.leadtime_p80_label'), data: @lead_time_info }, { name: I18n.t('general.dashboards.lead_time_in_month'), data: @lead_time_info_month }]
    end

    def build_throughput_info
      return [{ name: I18n.t('customer.charts.throughput.title'), data: [] }] if @demands.blank?

      [{ name: I18n.t('customer.charts.throughput.title'), data: @throughput_info }]
    end

    def build_risk_info
      [{ name: @contract.start_date, data: @contract.contract_consolidations.order(:consolidation_date).map(&:operational_risk_value).map { |risk_value| risk_value.to_f * 100 } }]
    end

    def build_hours_blocked_per_delivery_info
      return [{ name: I18n.t('customer.charts.hours_blocked_per_delivery.title'), data: [] }] if @demands.blank?

      [{ name: I18n.t('customer.charts.hours_blocked_per_delivery.title'), data: @hours_blocked_per_deliver_info }]
    end

    def build_external_dependency_info
      return [{ name: I18n.t('customer.charts.external_dependency.title'), data: [] }] if @demands.blank?

      [{ name: I18n.t('customer.charts.external_dependency.title'), data: @external_dependency_info }]
    end

    def build_effort_info
      [{ type: 'column', yAxis: 1, name: I18n.t('general.dashboards.hours_delivered'), data: @effort_hours_info_month }, { type: 'spline', name: I18n.t('general.dashboards.hours_delivered_acc'), data: @effort_hours_info }]
    end

    private

    def blank_burnup
      [{ name: I18n.t('charts.burnup.scope'), data: [] }, { name: I18n.t('charts.burnup.current'), data: [] }, { name: I18n.t('charts.burnup.ideal'), data: [] }]
    end

    def build_operations_charts_info(hour_value)
      @dates_array.each_with_index do |date, index|
        demands_delivered_to_date = demands_delivered_to_date(date)
        demands_delivered_in_month = demands_delivered_in_month(date)

        add_value_to_burnup_arrays(date, hour_value, index, demands_delivered_to_date)
        add_value_to_scope_burnup(date, index, demands_delivered_to_date.count)
        add_value_to_quality_chart(date, demands_delivered_to_date)
        add_value_to_quality_in_month_chart(date, demands_delivered_to_date)
        add_value_to_lead_time_chart(date, demands_delivered_to_date, demands_delivered_in_month)
        add_value_to_throughput_chart(date, demands_delivered_to_date)
        add_value_to_hours_blocked_per_deliver_chart(date, demands_delivered_to_date)
        add_value_to_external_dependency_chart(date, demands_delivered_to_date)
        add_value_to_effort_hours_info_chart(date, demands_delivered_to_date, demands_delivered_in_month)
      end
    end

    def demands_delivered_in_month(date)
      @demands.not_discarded_until(date.end_of_month).to_end_dates(date.beginning_of_month, date.end_of_month)
    end

    def demands_delivered_to_date(date)
      @demands.not_discarded_until(date.end_of_month).to_end_dates(@contract.start_date.beginning_of_month, date.end_of_month)
    end

    def add_value_to_burnup_arrays(date, hour_value, index, demands_delivered_to_date)
      total_effort = demands_delivered_to_date.map(&:total_effort).flatten.sum.to_f

      @financial_ideal << (@financial_ideal_slice * (index + 1))
      @financial_current << (total_effort * hour_value) if date <= @limit_date
      @financial_total << @total_financial_value

      @hours_ideal << (@hours_ideal_slice * (index + 1))
      @hours_current << total_effort if date <= @limit_date
      @hours_total << @total_hours_value
    end

    def add_value_to_scope_burnup(date, index, total_demands_delivered_to_date)
      @scope_ideal << (@scope_ideal_slice * (index + 1))
      @scope_current << total_demands_delivered_to_date if date <= @limit_date
      @scope_total << @total_scope_value
    end

    def add_value_to_quality_chart(date, demands_delivered_to_date)
      return if date > @limit_date

      bugs_opened_in_the_contract_count = @demands.kept.bug.where('created_date >= :start_date AND created_date <= :end_date', start_date: @contract.start_date, end_date: date).count
      @quality_info << if bugs_opened_in_the_contract_count.zero?
                         0
                       else
                         bugs_opened_in_the_contract_count.to_f / demands_delivered_to_date.count
                       end
    end

    def add_value_to_quality_in_month_chart(date, demands_delivered_to_date_in_month)
      return if date > @limit_date

      bugs_opened_in_the_month_count = @demands.kept.bug.where('created_date >= :start_date AND created_date <= :end_date', start_date: date.beginning_of_month, end_date: date.end_of_month).count
      @quality_info_month << if bugs_opened_in_the_month_count.zero?
                               0
                             else
                               bugs_opened_in_the_month_count.to_f / demands_delivered_to_date_in_month.count
                             end
    end

    def add_value_to_lead_time_chart(date, demands_delivered_to_date, demands_delivered_in_month)
      return if date > @limit_date

      @lead_time_info << Stats::StatisticsService.instance.percentile(80, demands_delivered_to_date.map(&:leadtime_in_days))
      @lead_time_info_month << Stats::StatisticsService.instance.percentile(80, demands_delivered_in_month.map(&:leadtime_in_days))
    end

    def add_value_to_throughput_chart(date, demands_delivered_to_date)
      return if date > @limit_date

      @throughput_info << demands_delivered_to_date.count
    end

    def add_value_to_hours_blocked_per_deliver_chart(date, demands_delivered_to_date)
      return if date > @limit_date

      @hours_blocked_per_deliver_info << if demands_delivered_to_date.count.positive?
                                           demands_delivered_to_date.sum(&:total_bloked_working_time) / demands_delivered_to_date.count
                                         else
                                           0
                                         end
    end

    def add_value_to_external_dependency_chart(date, demands_delivered_to_date)
      return if date > @limit_date

      products_ids = demands_delivered_to_date.map(&:product).flatten.map(&:id)

      @external_dependency_info << if demands_delivered_to_date.count.positive?
                                     DemandBlocksRepository.instance.demand_blocks_for_products(products_ids, date.beginning_of_month, date.end_of_month).external_dependency.count
                                   else
                                     0
                                   end
    end

    def add_value_to_effort_hours_info_chart(date, demands_delivered_to_date, demands_delivered_in_month)
      return if date > @limit_date

      @effort_hours_info << demands_delivered_to_date.map(&:total_effort).flatten.compact.sum.to_f
      @effort_hours_info_month << demands_delivered_in_month.map(&:total_effort).flatten.compact.sum.to_f
    end

    def build_dates_array(data_interval)
      @dates_array = dates_interval(data_interval, @contract.start_date, @contract.end_date)
    end

    def build_dates_limit_now_array(data_interval)
      end_date = [@contract.end_date, Time.zone.now.end_of_month].min
      @dates_limit_now_array = dates_interval(data_interval, @contract.start_date, end_date)
    end

    def dates_interval(data_interval, start_date, end_date)
      case data_interval
      when 'day'
        TimeService.instance.days_between_of(start_date, end_date)
      when 'week'
        TimeService.instance.weeks_between_of(start_date, end_date)
      else
        TimeService.instance.months_between_of(start_date, end_date)
      end
    end

    def build_limit_date(data_interval)
      @limit_date = case data_interval
                    when 'day'
                      Time.zone.today.end_of_day
                    when 'week'
                      Time.zone.today.end_of_week
                    else
                      Time.zone.today.end_of_month
                    end
    end

    def build_arrays
      @financial_total = []
      @financial_ideal = []
      @financial_current = []

      @hours_total = []
      @hours_ideal = []
      @hours_current = []

      @scope_total = []
      @scope_ideal = []
      @scope_current = []

      @quality_info = []
      @quality_info_month = []

      @lead_time_info = []
      @lead_time_info_month = []

      @throughput_info = []

      @hours_blocked_per_deliver_info = []

      @external_dependency_info = []
      @effort_hours_info = []
      @effort_hours_info_month = []
    end

    def build_hours_finances_constants
      @total_financial_value = @contract.total_value
      @financial_ideal_slice = @total_financial_value / @dates_array.count

      @total_hours_value = @contract.total_hours
      @hours_ideal_slice = @total_hours_value / @dates_array.count

      @consumed_hours = demands_finished_for_contracts.sum(&:total_effort)
      @remaining_hours = @total_hours_value - @consumed_hours
    end

    def build_scope_constants
      @total_scope_value = @contract.estimated_scope
      @scope_ideal_slice = @total_scope_value / @dates_array.count.to_f

      @delivered_demands_count = demands_finished_for_contracts.count
      @remaining_backlog_count = @total_scope_value - @delivered_demands_count
    end

    def demands_finished_for_contracts
      @demands_finished_for_contracts ||= @demands.not_discarded_until(@contract.start_date).finished_until_date(@contract.end_date).finished_after_date(@contract.start_date)
    end
  end
end
