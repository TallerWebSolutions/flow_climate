# frozen_string_literal: true

# == Schema Information
#
# Table name: user_company_roles
#
#  id         :integer          not null, primary key
#  end_date   :date
#  slack_user :string
#  start_date :date
#  user_role  :integer          default("operations"), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  company_id :integer
#  user_id    :integer
#
# Indexes
#
#  index_user_company_roles_on_company_id              (company_id)
#  index_user_company_roles_on_id                      (id)
#  index_user_company_roles_on_user_id                 (user_id)
#  index_user_company_roles_on_user_id_and_company_id  (user_id,company_id) UNIQUE
#  index_user_company_roles_on_user_role               (user_role)
#
# Foreign Keys
#
#  fk_rails_27539b2fc9  (user_id => users.id)
#  fk_rails_667cd952fb  (company_id => companies.id)
#

class UserCompanyRole < ApplicationRecord
  enum user_role: { operations: 0, manager: 1, director: 2, customer: 3 }

  belongs_to :user
  belongs_to :company

  validates :user, :company, presence: true

  validates :user, uniqueness: { scope: :company, message: I18n.t('user_company_role.validations.user_company') }

  delegate :first_name, :last_name, :email, to: :user
end
