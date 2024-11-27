# frozen_string_literal: true

# == Schema Information
#
# Table name: membership_available_hours_histories
#
#  id              :bigint           not null, primary key
#  available_hours :integer          not null
#  change_date     :datetime         not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  membership_id   :integer          not null
#
# Indexes
#
#  index_membership_available_hours_histories_on_membership_id  (membership_id)
#
# Foreign Keys
#
#  fk_rails_76a71f84ba  (membership_id => memberships.id)
#

module History
  class MembershipAvailableHoursHistory < ApplicationRecord
    belongs_to :membership

    validates :available_hours, :change_date, presence: true

    scope :until_date, ->(date) { where('change_date <= :limit_date', limit_date: date) }
  end
end
