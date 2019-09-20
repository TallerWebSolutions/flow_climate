# frozen_string_literal: true

# == Schema Information
#
# Table name: service_delivery_reviews
#
#  company_id                        :integer          not null, indexed
#  created_at                        :datetime         not null
#  delayed_expedite_bottom_threshold :decimal(, )      not null
#  delayed_expedite_top_threshold    :decimal(, )      not null
#  expedite_max_pull_time_sla        :integer          not null
#  id                                :bigint(8)        not null, primary key
#  lead_time_bottom_threshold        :decimal(, )      not null
#  lead_time_top_threshold           :decimal(, )      not null
#  meeting_date                      :date             not null, indexed => [product_id]
#  product_id                        :integer          not null, indexed => [meeting_date], indexed
#  quality_bottom_threshold          :decimal(, )      not null
#  quality_top_threshold             :decimal(, )      not null
#  updated_at                        :datetime         not null
#
# Indexes
#
#  index_service_delivery_reviews_on_company_id                   (company_id)
#  index_service_delivery_reviews_on_meeting_date_and_product_id  (meeting_date,product_id) UNIQUE
#  index_service_delivery_reviews_on_product_id                   (product_id)
#
# Foreign Keys
#
#  fk_rails_2ee3d597b3  (product_id => products.id)
#  fk_rails_bfbae75414  (company_id => companies.id)
#

class ServiceDeliveryReview < ApplicationRecord
  belongs_to :company
  belongs_to :product

  has_many :demands, dependent: :nullify

  validates :company, :product, :meeting_date, presence: true

  validates :product, uniqueness: { scope: :meeting_date, message: I18n.t('service_delivery_review.attributes.validations.product_uniqueness') }

  delegate :name, to: :product, prefix: true
  delegate :count, to: :bugs, prefix: true
  delegate :count, to: :expedites, prefix: true

  def bugs
    demands.kept.bug
  end

  def no_bugs
    demands.kept - demands.kept.bug
  end

  def bug_percentage
    return 0 unless demands.kept.count.positive?

    (bugs_count.to_f / demands.kept.count) * 100
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
    @demands_lead_time_p80 ||= Stats::StatisticsService.instance.percentile(80, demands.map(&:leadtime))
  end

  def lead_time_breakdown
    @lead_time_breakdown ||= DemandService.instance.lead_time_breakdown(demands)
  end

  def portfolio_module_breakdown
    @portfolio_module_breakdown ||= demands.where('portfolio_unit_id IS NOT NULL').group_by(&:portfolio_unit).sort_by { |_key, values| values.count }.to_h
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
    fit_for_purpose_demands = demands.kept - overserved_demands[:value] - underserved_demands[:value]
    { value: fit_for_purpose_demands, share: fit_for_purpose_demands.count.to_f / demands.kept.count }
  end

  def longest_stage
    @longest_stage ||= lead_time_breakdown.max_by { |_stages, transitions| transitions.sum(&:total_seconds_in_transition) }

    return {} if @longest_stage.blank?

    { name: @longest_stage[0], time_in_stage: @longest_stage[1].sum(&:total_seconds_in_transition) }
  end
end
