# frozen_string_literal: true

# == Schema Information
#
# Table name: service_delivery_reviews
#
#  id                                :integer          not null, primary key
#  company_id                        :integer          not null
#  product_id                        :integer          not null
#  meeting_date                      :date             not null
#  lead_time_top_threshold           :decimal(, )      not null
#  lead_time_bottom_threshold        :decimal(, )      not null
#  quality_top_threshold             :decimal(, )      not null
#  quality_bottom_threshold          :decimal(, )      not null
#  expedite_max_pull_time_sla        :integer          not null
#  delayed_expedite_top_threshold    :decimal(, )      not null
#  delayed_expedite_bottom_threshold :decimal(, )      not null
#  created_at                        :datetime         not null
#  updated_at                        :datetime         not null
#  bugs_ids                          :integer          is an Array
#
# Indexes
#
#  index_service_delivery_reviews_on_company_id                   (company_id)
#  index_service_delivery_reviews_on_meeting_date_and_product_id  (meeting_date,product_id) UNIQUE
#  index_service_delivery_reviews_on_product_id                   (product_id)
#

class ServiceDeliveryReview < ApplicationRecord
  belongs_to :company
  belongs_to :product

  has_many :demands, dependent: :nullify
  has_many :service_delivery_review_action_items, dependent: :destroy

  validates :meeting_date, presence: true

  validates :meeting_date, uniqueness: { scope: :product, message: I18n.t('service_delivery_review.attributes.validations.product_uniqueness') }

  delegate :name, to: :product, prefix: true
  delegate :count, to: :bugs, prefix: true
  delegate :count, to: :expedites, prefix: true

  def bugs
    Demand.where(id: bugs_ids)
  end

  def no_bugs
    demands.kept - bugs
  end

  def bug_percentage
    return 0 unless demands.kept.count.positive? && demands.kept.bug.count&.positive?

    (demands.kept.bug.count.to_f / demands.kept.count) * 100
  end

  def expedites
    @expedites ||= demands.kept.expedite
  end

  def expedites_delayed
    @expedites_delayed ||= expedites.kept.select { |demand| demand.time_between_commitment_and_pull > expedite_max_pull_time_sla }
  end

  def expedites_not_delayed
    @expedites_not_delayed ||= expedites - expedites_delayed
  end

  def expedites_delayed_share
    return 0.0 if expedites.kept.count.zero?

    expedites_delayed.count.to_f / expedites.kept.count
  end

  def demands_lead_time_p80
    @demands_lead_time_p80 ||= Stats::StatisticsService.instance.percentile(80, demands.kept.map(&:leadtime))
  end

  def lead_time_breakdown
    @lead_time_breakdown ||= DemandService.instance.lead_time_breakdown(demands.kept)
  end

  def portfolio_module_breakdown
    @portfolio_module_breakdown ||= demands.kept.where.not(portfolio_unit_id: nil).group_by(&:portfolio_unit).sort_by { |_key, values| values.count }.to_h
  end

  def overserved_demands
    overserved_demands = demands.kept.where('leadtime < :lead_time_bottom_limit', lead_time_bottom_limit: lead_time_bottom_threshold)
    { value: overserved_demands, share: overserved_demands.count.to_f / demands.kept.count }
  end

  def underserved_demands
    underserved_demands = demands.kept.where('leadtime > :lead_time_top_limit', lead_time_top_limit: lead_time_top_threshold)
    { value: underserved_demands, share: underserved_demands.count.to_f / demands.kept.count }
  end

  def fit_for_purpose_demands
    fit_for_purpose_demands = Demand.where(id: (demands.kept - overserved_demands[:value] - underserved_demands[:value]).map(&:id))
    { value: fit_for_purpose_demands, share: fit_for_purpose_demands.count.to_f / demands.kept.count }
  end

  def longest_stage
    @longest_stage ||= lead_time_breakdown.max_by { |_stages, transitions| transitions.sum(&:total_seconds_in_transition) }

    return nil if @longest_stage.blank?

    { name: @longest_stage[0], time_in_stage: @longest_stage[1].sum(&:total_seconds_in_transition) }
  end

  def start_date
    demands.kept.map(&:end_date).min || meeting_date
  end
end
