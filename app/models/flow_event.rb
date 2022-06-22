# frozen_string_literal: true

# == Schema Information
#
# Table name: flow_events
#
#  id                :bigint           not null, primary key
#  discarded_at      :datetime
#  event_date        :date             not null
#  event_description :string           not null
#  event_end_date    :date
#  event_size        :integer          default("small"), not null
#  event_type        :integer          not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  company_id        :integer          not null
#  project_id        :integer
#  risk_review_id    :integer
#  team_id           :integer
#  user_id           :integer
#
# Indexes
#
#  index_flow_events_on_event_size  (event_size)
#  index_flow_events_on_event_type  (event_type)
#  index_flow_events_on_project_id  (project_id)
#  index_flow_events_on_user_id     (user_id)
#
# Foreign Keys
#
#  fk_rails_80b183dabb  (user_id => users.id)
#  fk_rails_c718f8e04c  (risk_review_id => risk_reviews.id)
#  fk_rails_cda32ac094  (project_id => projects.id)
#

class FlowEvent < ApplicationRecord
  include Discard::Model
  include Rails.application.routes.url_helpers

  enum event_type: { other_team_dependency: 0, api_not_ready: 1, customer_not_available: 2, other_demand_dependency: 3, fixes_out_of_scope: 4, external_service_unavailable: 5, day_off: 6 }
  enum event_size: { small: 0, medium: 1, large: 2 }

  belongs_to :company
  belongs_to :user
  belongs_to :team, optional: true
  belongs_to :project, optional: true
  belongs_to :risk_review, optional: true

  validates :event_date, :event_type, :event_size, :event_description, presence: true

  def to_hash
    {
      project_name: project.name,
      event_type: I18n.t("activerecord.attributes.flow_event.enums.event_type.#{event_type}"),
      event_size: I18n.t("activerecord.attributes.flow_event.enums.event_size.#{event_size}"),
      event_date: event_date.iso8601,
      event_end_date: event_end_date&.iso8601,
      event_url: company_flow_event_path(project.company, self)
    }
  end
end
