# frozen-string-literal: true

# == Schema Information
#
# Table name: item_assignment_notifications
#
#  id                 :bigint           not null, primary key
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  item_assignment_id :integer          not null
#
# Indexes
#
#  index_item_assignment_notifications_on_item_assignment_id  (item_assignment_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_07fec2e0f5  (item_assignment_id => item_assignments.id)
#

class ItemAssignmentNotification < ApplicationRecord
  belongs_to :item_assignment

  validates :item_assignment, presence: true
end
