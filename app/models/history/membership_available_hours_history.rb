# frozen_string_literal: true

# == Schema Information
#
# Table name: membership_available_hours_histories
#
#  id              :integer          not null, primary key
#  membership_id   :integer          not null
#  available_hours :integer          not null
#  change_date     :datetime         not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_membership_available_hours_histories_on_membership_id  (membership_id)
#

module History
  class MembershipAvailableHoursHistory < ApplicationRecord
    belongs_to :membership

    validates :available_hours, :change_date, presence: true

    scope :until_date, ->(date) { where('change_date <= :limit_date', limit_date: date) }
  end
end
