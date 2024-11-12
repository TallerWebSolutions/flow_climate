# frozen_string_literal: true

# == Schema Information
#
# Table name: user_invites
#
#  id               :integer          not null, primary key
#  company_id       :integer          not null
#  invite_status    :integer          not null
#  invite_type      :integer          not null
#  invite_object_id :integer          not null
#  invite_email     :string           not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
# Indexes
#
#  index_user_invites_on_company_id        (company_id)
#  index_user_invites_on_invite_email      (invite_email)
#  index_user_invites_on_invite_object_id  (invite_object_id)
#  index_user_invites_on_invite_status     (invite_status)
#  index_user_invites_on_invite_type       (invite_type)
#

class UserInvite < ApplicationRecord
  enum :invite_status, { pending: 0, accepted: 1, cancelled: 2 }
  enum :invite_type, { company: 0, customer: 1, product: 2, project: 3 }

  belongs_to :company

  validates :invite_type, :invite_email, :invite_object_id, :invite_status, presence: true

  validate :same_invite?

  private

  def same_invite?
    existent_invite = UserInvite.where(invite_email: invite_email, company: company).where.not(invite_status: UserInvite.invite_statuses[:cancelled])
    return false if existent_invite.first&.id == id || existent_invite.blank?

    errors.add(:invite_email, I18n.t('activerecord.errors.models.user_invite.invite_email.not_same'))
  end
end
