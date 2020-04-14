# frozen_string_literal: true

module Flow
  class SystemFlowInformations
    attr_reader :demands, :demands_ids, :demands_ids_in_products, :current_limit_date, :data_point_index

    def initialize(demands)
      start_common_attributes

      return if demands.blank?

      return if products_in_data(demands).blank?

      @demands = demands.order('end_date, commitment_date, created_date')
      @demands_ids = @demands.map(&:id)

      @demands_ids_in_products = Demand.where(id: products_in_data(demands).includes([:demands]).map { |product| product.demands.map(&:id) }.flatten).kept.map(&:id)
    end

    private

    def products_in_data(demands)
      @products_in_data ||= Product.where(id: demands.includes([:product]).map(&:product).uniq.compact.map(&:id))
    end

    def start_common_attributes
      @demands = Demand.none
      @demands_ids = []
      @current_limit_date = Time.zone.today.end_of_week
    end
  end
end
