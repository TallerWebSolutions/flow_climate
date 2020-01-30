# frozen_string_literal: true

# == Schema Information
#
# Table name: flow_impacts
#
#  id                 :bigint           not null, primary key
#  discarded_at       :datetime
#  impact_date        :datetime         not null
#  impact_description :string           not null
#  impact_size        :integer          default("small"), not null
#  impact_type        :integer          not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  demand_id          :integer
#  project_id         :integer          not null
#  risk_review_id     :integer
#  user_id            :integer
#
# Indexes
#
#  index_flow_impacts_on_demand_id    (demand_id)
#  index_flow_impacts_on_impact_size  (impact_size)
#  index_flow_impacts_on_impact_type  (impact_type)
#  index_flow_impacts_on_project_id   (project_id)
#  index_flow_impacts_on_user_id      (user_id)
#
# Foreign Keys
#
#  fk_rails_80b183dabb  (user_id => users.id)
#  fk_rails_c718f8e04c  (risk_review_id => risk_reviews.id)
#  fk_rails_cda32ac094  (project_id => projects.id)
#  fk_rails_f6118b7a74  (demand_id => demands.id)
#

class FlowImpact < ApplicationRecord
  include Discard::Model
  include Rails.application.routes.url_helpers

  enum impact_type: { other_team_dependency: 0, api_not_ready: 1, customer_not_available: 2, other_demand_dependency: 3, fixes_out_of_scope: 4, external_service_unavailable: 5 }
  enum impact_size: { small: 0, medium: 1, large: 2 }

  belongs_to :user
  belongs_to :project
  belongs_to :demand
  belongs_to :risk_review

  validates :project, :impact_date, :impact_type, :impact_size, :impact_description, presence: true

  def to_hash
    {
      project_name: project.name,
      impact_type: I18n.t("activerecord.attributes.flow_impact.enums.impact_type.#{impact_type}"),
      impact_size: I18n.t("activerecord.attributes.flow_impact.enums.impact_size.#{impact_size}"),
      demand: demand&.external_id,
      impact_date: impact_date.iso8601,
      impact_url: company_flow_impact_path(project.company, self)
    }
  end
end
