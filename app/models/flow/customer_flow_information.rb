# frozen_string_literal: true

module Flow
  class CustomerFlowInformation < SystemFlowInformation
    attr_reader :dates_array, :customer, :limit_date,
                :financial_ideal, :financial_current, :financial_ideal_slice, :financial_total, :total_financial_value,
                :hours_ideal, :hours_current, :hours_ideal_slice, :hours_total, :total_hours_value,
                :scope_ideal, :scope_current, :scope_ideal_slice, :scope_total, :total_scope_value

    def initialize(customer, data_interval = 'month')
      super(customer.demands)

      @customer = customer
      @financial_burnup = {}

      build_dates_array(data_interval)
      build_limit_date(data_interval)
      build_arrays

      hour_value = @customer.contracts.active.map(&:hour_value).sum.to_f / @customer.contracts.active.count

      build_burnup_constants
      build_burnup_scope_constants
      build_hours_and_cost_burnup_info(hour_value)
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

    private

    def blank_burnup
      [{ name: I18n.t('charts.burnup.scope'), data: [] }, { name: I18n.t('charts.burnup.current'), data: [] }, { name: I18n.t('charts.burnup.ideal'), data: [] }]
    end

    def build_hours_and_cost_burnup_info(hour_value)
      @dates_array.each_with_index do |date, index|
        total_demands_delivered_to_date = @demands.kept.finished_until_date(date).finished_after_date(start_date)
        total_effort = total_demands_delivered_to_date.map(&:total_effort).flatten.sum.to_f

        add_value_to_burnup_arrays(date, hour_value, index, total_effort)
        add_value_to_scope_burnup(date, index, total_demands_delivered_to_date.count)
      end
    end

    def add_value_to_burnup_arrays(date, hour_value, index, total_effort)
      @financial_ideal << @financial_ideal_slice * (index + 1)
      @financial_current << total_effort * hour_value if date <= @limit_date
      @financial_total << @total_financial_value

      @hours_ideal << @hours_ideal_slice * (index + 1)
      @hours_current << total_effort if date <= @limit_date
      @hours_total << @total_hours_value
    end

    def add_value_to_scope_burnup(date, index, total_demands_delivered_to_date)
      @scope_ideal << @scope_ideal_slice * (index + 1)
      @scope_current << total_demands_delivered_to_date if date <= @limit_date
      @scope_total << @total_scope_value
    end

    def build_dates_array(data_interval)
      @dates_array = if data_interval == 'day'
                       TimeService.instance.days_between_of(start_date, end_date)
                     elsif data_interval == 'week'
                       TimeService.instance.weeks_between_of(start_date, end_date)
                     else
                       TimeService.instance.months_between_of(start_date, end_date)
                     end
    end

    def build_limit_date(data_interval)
      @limit_date = if data_interval == 'day'
                      Time.zone.today.end_of_day
                    elsif data_interval == 'week'
                      Time.zone.today.end_of_week
                    else
                      Time.zone.today.end_of_month
                    end
    end

    def start_date
      @customer.contracts.active.map(&:start_date).flatten.min || Time.zone.today
    end

    def end_date
      @customer.contracts.active.map(&:end_date).flatten.max || Time.zone.today
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
    end

    def build_burnup_constants
      @total_financial_value = @customer.contracts.active.map(&:total_value).sum
      @financial_ideal_slice = @total_financial_value / @dates_array.count

      @total_hours_value = @customer.contracts.active.map(&:total_hours).sum
      @hours_ideal_slice = @total_hours_value / @dates_array.count
    end

    def build_burnup_scope_constants
      @total_scope_value = @customer.contracts.active.sum(&:estimated_scope)
      @scope_ideal_slice = @total_scope_value / @dates_array.count.to_f
    end
  end
end
