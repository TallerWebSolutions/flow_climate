# frozen_string_literal: true

# == Schema Information
#
# Table name: work_item_types
#
#  id                     :bigint           not null, primary key
#  item_level             :integer          default("demand"), not null
#  name                   :string           not null
#  quality_indicator_type :boolean          default(FALSE), not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  company_id             :integer          not null
#
# Indexes
#
#  index_work_item_types_on_company_id                          (company_id)
#  index_work_item_types_on_company_id_and_item_level_and_name  (company_id,item_level,name) UNIQUE
#  index_work_item_types_on_item_level                          (item_level)
#  index_work_item_types_on_quality_indicator_type              (quality_indicator_type)
#
# Foreign Keys
#
#  fk_rails_8c3c9d6119  (company_id => companies.id)
#
class WorkItemType < ApplicationRecord
  enum :item_level, { demand: 0, task: 1 }

  belongs_to :company
  has_many :demands, dependent: :restrict_with_error
  has_many :tasks, dependent: :restrict_with_error

  validates :item_level, :name, presence: true

  validates :name, uniqueness: { scope: %i[company_id item_level] }
end
