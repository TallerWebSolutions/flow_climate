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
#  language               :string           default("pt-BR"), not null
#  last_name              :string           not null
#  last_sign_in_at        :datetime
#  last_sign_in_ip        :inet
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  sign_in_count          :integer          default(0), not null
#  user_money_credits     :decimal(, )      default(0.0), not null
#  user_role              :integer          default("user"), not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  last_company_id        :integer
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

  enum :user_role, { user: 0, manager: 1, admin: 10 }

  has_many :user_company_roles, dependent: :destroy
  has_many :companies, through: :user_company_roles
  belongs_to :last_company, class_name: 'Company', optional: true

  has_many :user_project_roles, dependent: :destroy

  has_one :team_member, dependent: :restrict_with_error

  has_many :memberships, through: :team_member
  has_many :item_assignments, through: :memberships
  has_many :demands, -> { distinct }, through: :item_assignments
  has_many :product_users, dependent: :destroy
  has_many :products, through: :product_users
  has_many :projects, through: :products

  has_many :user_plans, dependent: :destroy

  validates :first_name, :last_name, :email, presence: true

  scope :to_notify_email, -> { where email_notifications: true }
  scope :admins, -> { where admin: true }

  delegate :pairing_members, to: :team_member, allow_nil: true

  # Overrided just for the transition from boolean to enum
  def admin?
    admin
  end

  def active_access_to_company?(company)
    active_companies = companies.joins(:user_company_roles).where(user_company_roles: { end_date: nil })

    active_companies.include?(company)
  end

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
    "#{first_name} #{last_name}"
  end

  def toggle_admin
    return update(admin: false, user_role: :user) if admin

    update(admin: true, user_role: :admin)
  end

  def role_in_company(company)
    user_company_roles.find_by(company: company)
  end

  def managing_company?(company)
    user_company_roles.find_by(company: company).user_role_before_type_cast.positive?
  end

  def slack_user_for_company(company)
    user_company_roles.find_by(company: company)&.slack_user
  end
end
