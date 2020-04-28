# frozen_string_literal: true

# == Schema Information
#
# Table name: user_invites
#
#  id               :bigint           not null, primary key
#  invite_email     :string           not null
#  invite_status    :integer          not null
#  invite_type      :integer          not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  company_id       :integer          not null
#  invite_object_id :integer          not null
#
# Indexes
#
#  index_user_invites_on_company_id        (company_id)
#  index_user_invites_on_invite_email      (invite_email)
#  index_user_invites_on_invite_object_id  (invite_object_id)
#  index_user_invites_on_invite_status     (invite_status)
#  index_user_invites_on_invite_type       (invite_type)
#
# Foreign Keys
#
#  fk_rails_b2aa9bf2c0  (company_id => companies.id)
#
class UserInvite < ApplicationRecord
  enum invite_status: { pending: 0, accepted: 1, cancelled: 2 }
  enum invite_type: { company: 0, customer: 1, product: 2, project: 3 }

  belongs_to :company

  validates :company, :invite_type, :invite_email, :invite_object_id, :invite_status, presence: true

  validate :same_invite?

  private

  def same_invite?
    existent_invite = UserInvite.where(invite_email: invite_email, company: company).where('invite_status <> :status', status: UserInvite.invite_statuses[:cancelled])
    return if existent_invite.blank?

    errors.add(:invite_email, I18n.t('activerecord.errors.models.user_invite.invite_email.not_same'))
  end
end
