# frozen_string_literal: true

module Flow
  class WorkItemFlowInformations < SystemFlowInformations
    attr_reader :scope_per_period, :ideal_per_period, :throughput_per_period, :accumulated_throughput, :accumulated_bugs_opened_data_array,
                :accumulated_bugs_closed_data_array, :bugs_opened_data_array, :bugs_closed_data_array, :bugs_share_data_array,
                :upstream_total_delivered, :upstream_delivered_per_period, :downstream_total_delivered, :downstream_delivered_per_period,
                :uncertain_scope, :current_scope, :period_size

    def initialize(dates_array, current_limit_date, demands, uncertain_scope_amount)
      super(dates_array, current_limit_date, demands)
      @uncertain_scope = uncertain_scope_amount
      start_arrays

      limit_data_analysis_date = dates_array.last || Time.zone.now

      @current_scope = @demands.opened_before_date(limit_data_analysis_date).count + @uncertain_scope
      @period_size = @dates_array.count.to_f

      work_items_flow_behaviour
    end

    def work_items_flow_behaviour
      @dates_array.each_with_index do |date, index|
        demands_in_period = DemandsRepository.instance.known_scope_to_date(@demands_ids, date) # query

        @scope_per_period << demands_in_period.count + @uncertain_scope
        build_ideal_burn_segment(index)

        next if @current_limit_date < date

        build_flow_data(date, demands_in_period)
      end
    end

    private

    def build_flow_data(date, demands_in_period)
      demands_finished_until_date = demands_in_period.finished_until_date(date) # query
      demands_delivered_upstream = demands_finished_until_date.finished_in_upstream # query
      demands_delivered_downstream = demands_finished_until_date.finished_in_downstream # query

      build_upstream_data_array(demands_delivered_upstream)
      build_downstream_data_array(demands_delivered_downstream)
      build_throughput_per_period_data_array(demands_delivered_upstream, demands_delivered_downstream)
      build_bugs_data_array(demands_in_period.kept.bug.count, demands_finished_until_date.kept.bug.count, demands_in_period.kept.count)
    end

    def build_ideal_burn_segment(index)
      @ideal_per_period << (@current_scope.to_f / @period_size) * (index + 1)
    end

    def build_throughput_per_period_data_array(demands_delivered_upstream, demands_delivered_downstream)
      total_delivered_in_period = (demands_delivered_upstream.count + demands_delivered_downstream.count)
      @throughput_per_period << (total_delivered_in_period - @accumulated_throughput.last.to_i)

      @accumulated_throughput << total_delivered_in_period
    end

    def build_downstream_data_array(demands_delivered_downstream)
      @downstream_delivered_per_period << (demands_delivered_downstream.count - @downstream_total_delivered.last.to_i)
      @downstream_total_delivered << demands_delivered_downstream.count
    end

    def build_upstream_data_array(demands_delivered_upstream)
      @upstream_delivered_per_period << (demands_delivered_upstream.count - @upstream_total_delivered.last.to_i)
      @upstream_total_delivered << demands_delivered_upstream.count
    end

    def build_bugs_data_array(bugs_created_until_date_count, bugs_finished_until_date_count, demands_created_until_date_count)
      @bugs_opened_data_array << bugs_created_until_date_count - @accumulated_bugs_opened_data_array.last.to_i
      @bugs_closed_data_array << bugs_finished_until_date_count - @accumulated_bugs_closed_data_array.last.to_i

      @accumulated_bugs_opened_data_array << bugs_created_until_date_count
      @accumulated_bugs_closed_data_array << bugs_finished_until_date_count

      @bugs_share_data_array << (bugs_created_until_date_count.to_f / demands_created_until_date_count) * 100
    end

    def start_arrays
      @scope_per_period = []
      @ideal_per_period = []
      @upstream_total_delivered = []
      @accumulated_throughput = []
      @throughput_per_period = []
      @accumulated_throughput = []
      @upstream_delivered_per_period = []
      @upstream_total_delivered = []
      @downstream_total_delivered = []
      @downstream_delivered_per_period = []
      @accumulated_bugs_opened_data_array = []
      @accumulated_bugs_closed_data_array = []
      @bugs_share_data_array = []
      @bugs_opened_data_array = []
      @bugs_closed_data_array = []
    end
  end
end
