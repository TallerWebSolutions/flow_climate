# frozen_string_literal: true

module Flow
  class WorkItemFlowInformation < SystemFlowInformation
    attr_reader :scope_per_period, :ideal_per_period, :throughput_per_period, :accumulated_throughput,
                :products_throughput_per_period, :accumulated_products_throughput, :accumulated_bugs_opened_data_array,
                :accumulated_bugs_closed_data_array, :bugs_opened_data_array, :bugs_closed_data_array, :bugs_share_data_array,
                :upstream_total_delivered, :upstream_delivered_per_period, :downstream_total_delivered, :downstream_delivered_per_period,
                :uncertain_scope, :current_scope, :period_size, :demands_stages_count_hash, :data_period

    def initialize(demands, uncertain_scope_amount, period_size, end_sample_date, data_period)
      super(demands)
      start_attributes

      return if demands.blank?

      @uncertain_scope = uncertain_scope_amount

      end_sample_date ||= Time.zone.today

      @current_scope = @demands.opened_before_date(end_sample_date).count + @uncertain_scope
      @period_size = period_size
      teams = demands.map(&:team).uniq

      @stages = teams.last.stages.downstream.where('stages.order >= 0').order(:order)

      @data_period = data_period
    end

    def work_items_flow_behaviour(start_population_date, analysed_date, distribution_index, add_data_to_chart)
      return if demands.blank?

      demands_in_period = DemandsRepository.instance.known_scope_to_date(@demands_ids, analysed_date) # query
      demands_in_product = DemandsRepository.instance.known_scope_to_date(@demands_ids_in_products, analysed_date).order(:end_date) # query

      @scope_per_period << (demands_in_period.count + @uncertain_scope)
      build_ideal_burn_segment(distribution_index)

      build_flow_data(start_population_date, analysed_date, demands_in_period) if add_data_to_chart == true
      build_products_flow_data(start_population_date, analysed_date, demands_in_product) if add_data_to_chart == true
    end

    def build_cfd_hash(start_population_date, analysed_date)
      return if analysed_date > TimeService.instance.end_of_period_for_date(Time.zone.today, @data_period)

      demand_transitions = DemandTransition.for_demands_ids(@demands_ids)

      @stages.each do |stage|
        transitions_until_date = demand_transitions.select('DISTINCT demand_id').after_date(start_population_date).before_date_after_stage(analysed_date.end_of_day, stage.order).count

        if @demands_stages_count_hash[stage.name].present?
          @demands_stages_count_hash[stage.name] << transitions_until_date
        else
          @demands_stages_count_hash[stage.name] = [transitions_until_date]
        end
      end
    end

    def throughput_array_for_monte_carlo
      if (throughput_per_period.size >= 10) && throughput_per_period.reject(&:zero?).present?
        @throughput_per_period.last(10)
      else
        @products_throughput_per_period.last(10)
      end
    end

    def demands_tags_hash
      demands_tags = demands.map(&:demand_tags).flatten.compact.uniq

      demands_tags_hash = {}
      demands_tags.each { |demand_tag| demands_tags_hash[demand_tag] = DemandsRepository.instance.demand_tags_query(demands, [demand_tag]).count }
      demands_tags_hash.sort_by { |key, value| [-value, key.downcase] }
    end

    private

    def build_flow_data(bottom_limit_date, upper_limit_date, demands_in_period)
      demands_delivered_to_date = demands_in_period.not_discarded_until(upper_limit_date).finished_after_date(bottom_limit_date).finished_until_date(upper_limit_date)
      demands_delivered_upstream = demands_delivered_to_date.finished_in_upstream
      demands_delivered_downstream = demands_delivered_to_date.finished_in_downstream

      build_upstream_data_array(demands_delivered_upstream)
      build_downstream_data_array(demands_delivered_downstream)
      build_throughput_per_period_data_array(demands_delivered_upstream, demands_delivered_downstream)
      build_bugs_data_array(demands_in_period.bug.count, demands_delivered_to_date.bug.count, demands_in_period.count)
    end

    def build_products_flow_data(bottom_limit_date, upper_limit_date, demands_in_period)
      demands_delivered_to_date = demands_in_period.not_discarded_until(upper_limit_date).finished_after_date(bottom_limit_date).finished_until_date(upper_limit_date).count

      @products_throughput_per_period << (demands_delivered_to_date - @accumulated_products_throughput.last.to_i)

      @accumulated_products_throughput << demands_delivered_to_date
    end

    def build_ideal_burn_segment(index)
      @ideal_per_period << ((@current_scope.to_f / @period_size) * (index + 1))
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
      @bugs_opened_data_array << (bugs_created_until_date_count - @accumulated_bugs_opened_data_array.last.to_i)
      @bugs_closed_data_array << (bugs_finished_until_date_count - @accumulated_bugs_closed_data_array.last.to_i)

      @accumulated_bugs_opened_data_array << bugs_created_until_date_count
      @accumulated_bugs_closed_data_array << bugs_finished_until_date_count

      @bugs_share_data_array << ((bugs_created_until_date_count.to_f / demands_created_until_date_count) * 100)
    end

    def start_attributes
      @demands_stages_count_hash = {}
      @uncertain_scope = 0
      @current_scope = 0
      @period_size = 0
      @upstream_total_delivered = []
      @upstream_delivered_per_period = []
      @upstream_total_delivered = []
      @downstream_total_delivered = []
      @downstream_delivered_per_period = []
      @stages = []

      start_throughputs_array
      start_burnup_array
      start_bugs_array
    end

    def start_throughputs_array
      @accumulated_throughput = []
      @throughput_per_period = []
      @products_throughput_per_period = []
      @accumulated_products_throughput = []
    end

    def start_burnup_array
      @scope_per_period = []
      @ideal_per_period = []
    end

    def start_bugs_array
      @bugs_share_data_array = []
      @bugs_opened_data_array = []
      @bugs_closed_data_array = []
      @accumulated_bugs_opened_data_array = []
      @accumulated_bugs_closed_data_array = []
    end
  end
end
