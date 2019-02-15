# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  admin                  :boolean          default(FALSE), not null
#  avatar                 :string
#  created_at             :datetime         not null
#  current_sign_in_at     :datetime
#  current_sign_in_ip     :inet
#  email                  :string           not null, indexed
#  email_notifications    :boolean          default(FALSE), not null
#  encrypted_password     :string           not null
#  first_name             :string           not null
#  id                     :integer          not null, primary key
#  last_company_id        :integer
#  last_name              :string           not null
#  last_sign_in_at        :datetime
#  last_sign_in_ip        :inet
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string           indexed
#  sign_in_count          :integer          default(0), not null
#  updated_at             :datetime         not null
#  user_money_credits     :decimal(, )      default(0.0), not null
#
# Indexes
#
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#
# Foreign Keys
#
#  fk_rails_971bf2d9a1  (last_company_id => companies.id)
#

class User < ApplicationRecord
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :trackable, :validatable

  mount_uploader :avatar, FlowClimateImageUploader

  has_and_belongs_to_many :companies

  has_many :user_project_roles, dependent: :destroy
  has_many :projects, through: :user_project_roles

  has_many :demand_data_processments, dependent: :destroy
  has_many :user_plans, dependent: :destroy

  validates :first_name, :last_name, :email, presence: true

  scope :to_notify_email, -> { where email_notifications: true }
  scope :admins, -> { where admin: true }

  def current_plan
    current_user_plan&.plan
  end

  def current_user_plan
    user_plans.valid_plans.first
  end

  def trial?
    return false if current_plan.blank?

    current_plan.trial?
  end

  def lite?
    return false if current_plan.blank?

    current_plan.lite?
  end

  def gold?
    return false if current_plan.blank?

    current_plan.gold?
  end

  def no_plan?
    return true if current_plan.blank?

    false
  end

  def full_name
    "#{last_name}, #{first_name}"
  end

  def toggle_admin
    return update(admin: false) if admin?

    update(admin: true)
  end
end
