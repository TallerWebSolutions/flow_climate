# frozen_string_literal: true

# == Schema Information
#
# Table name: initiatives
#
#  id         :bigint           not null, primary key
#  end_date   :date             not null
#  name       :string           not null
#  start_date :date             not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  company_id :integer          not null
#
# Indexes
#
#  index_initiatives_on_company_id           (company_id)
#  index_initiatives_on_company_id_and_name  (company_id,name) UNIQUE
#  index_initiatives_on_name                 (name)
#
# Foreign Keys
#
#  fk_rails_8fd87a6ae5  (company_id => companies.id)
#

class Initiative < ApplicationRecord
  belongs_to :company

  has_many :projects, dependent: :destroy
  has_many :demands, through: :projects
  has_many :tasks, through: :projects

  validates :name, presence: true

  validates :name, uniqueness: { scope: :company_id, case_sensitive: false }
end
