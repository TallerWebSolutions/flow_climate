# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  admin                  :boolean          default(FALSE), not null
#  avatar                 :string
#  current_sign_in_at     :datetime
#  current_sign_in_ip     :inet
#  email                  :string           not null
#  email_notifications    :boolean          default(FALSE), not null
#  encrypted_password     :string           not null
#  first_name             :string           not null
#  last_name              :string           not null
#  last_sign_in_at        :datetime
#  last_sign_in_ip        :inet
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  sign_in_count          :integer          default(0), not null
#  user_money_credits     :decimal(, )      default(0.0), not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#

class User < ApplicationRecord
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :trackable, :validatable

  mount_uploader :avatar, FlowClimateImageUploader

  has_and_belongs_to_many :companies

  has_many :user_project_roles, dependent: :destroy
  has_many :projects, through: :user_project_roles

  has_one :team_member, dependent: :restrict_with_error

  has_many :item_assignments, through: :team_member
  has_many :demands, through: :item_assignments

  has_many :demand_data_processments, dependent: :destroy
  has_many :user_plans, dependent: :destroy

  validates :first_name, :last_name, :email, presence: true

  scope :to_notify_email, -> { where email_notifications: true }
  scope :admins, -> { where admin: true }

  delegate :pairing_members, to: :team_member, allow_nil: true

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

  def acting_projects
    Project.all.running.where(id: demands.kept.map(&:project_id))
  end

  def last_company
    Company.find(last_company_id) if last_company_id.present?
  end
end
