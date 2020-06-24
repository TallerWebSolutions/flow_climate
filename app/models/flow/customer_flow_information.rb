# frozen_string_literal: true

module Flow
  class CustomerFlowInformation < SystemFlowInformation
    attr_reader :financial_burnup, :dates_array, :customer, :limit_date

    def initialize(customer, data_interval = 'month')
      super(customer.demands)

      @customer = customer
      @financial_burnup = {}
      build_dates_array(data_interval)
      build_limit_date(data_interval)
    end

    def build_financial_burnup
      return blank_burnup if @demands.blank?

      total_value = @customer.contracts.active.map(&:total_value).sum
      hour_value = @customer.contracts.active.map(&:hour_value).sum.to_f / @customer.contracts.active.count

      ideal_slice = total_value / @dates_array.count

      build_cost_burnup(hour_value, ideal_slice, total_value)
    end

    private

    def blank_burnup
      [{ name: I18n.t('charts.burnup.scope'), data: [] }, { name: I18n.t('charts.burnup.current'), data: [] }, { name: I18n.t('charts.burnup.ideal'), data: [] }]
    end

    def build_cost_burnup(hour_value, ideal_slice, total_value)
      ideal_burn = []
      current_burn = []
      total_value_array = []

      @dates_array.each_with_index do |date, index|
        ideal_burn << ideal_slice * (index + 1)
        current_burn << @demands.kept.finished_until_date(date).finished_after_date(start_date).map(&:total_effort).flatten.sum.to_f * hour_value if date <= @limit_date
        total_value_array << total_value
      end

      [{ name: I18n.t('charts.burnup.scope'), data: total_value_array }, { name: I18n.t('charts.burnup.current'), data: current_burn }, { name: I18n.t('charts.burnup.ideal'), data: ideal_burn }]
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
  end
end
