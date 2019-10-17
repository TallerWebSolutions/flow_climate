# frozen_string_literal: true

# == Schema Information
#
# Table name: flow_impacts
#
#  created_at         :datetime         not null
#  demand_id          :integer          indexed
#  discarded_at       :datetime
#  end_date           :datetime
#  id                 :bigint(8)        not null, primary key
#  impact_description :string           not null
#  impact_type        :integer          not null, indexed
#  project_id         :integer          not null, indexed
#  risk_review_id     :integer
#  start_date         :datetime         not null
#  updated_at         :datetime         not null
#
# Foreign Keys
#
#  fk_rails_c718f8e04c  (risk_review_id => risk_reviews.id)
#  fk_rails_cda32ac094  (project_id => projects.id)
#  fk_rails_f6118b7a74  (demand_id => demands.id)
#

class FlowImpact < ApplicationRecord
  include Discard::Model
  include Rails.application.routes.url_helpers

  enum impact_type: { other_team_dependency: 0, api_not_ready: 1, customer_not_available: 2, other_demand_dependency: 3, fixes_out_of_scope: 4, external_service_unavailable: 5 }

  belongs_to :project
  belongs_to :demand
  belongs_to :risk_review

  validates :project, :start_date, :impact_type, :impact_description, presence: true

  scope :opened, -> { where(end_date: nil) }

  def impact_duration
    return Time.zone.now - start_date if end_date.blank?

    end_date - start_date
  end

  def to_hash
    {
      project_name: project.name,
      impact_type: I18n.t("activerecord.attributes.flow_impact.enums.impact_type.#{impact_type}"),
      demand: demand&.external_id,
      start_date: start_date.iso8601,
      end_date: end_date&.iso8601,
      impact_duration: impact_duration,
      impact_url: company_flow_impact_path(project.company, self)
    }
  end
end
