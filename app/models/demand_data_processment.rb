# frozen_string_literal: true

# == Schema Information
#
# Table name: demand_data_processments
#
#  id                 :bigint           not null, primary key
#  downloaded_content :text             not null
#  project_key        :string           not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  user_id            :integer          not null
#  user_plan_id       :integer          not null
#
# Indexes
#
#  index_demand_data_processments_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_1e9a84a8ab  (user_plan_id => user_plans.id)
#  fk_rails_337e2008a8  (user_id => users.id)
#

class DemandDataProcessment < ApplicationRecord
  belongs_to :user
  belongs_to :user_plan

  validates :user, :user_plan, :downloaded_content, :project_key, presence: true
end
