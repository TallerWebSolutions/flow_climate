# frozen_string_literal: true

# == Schema Information
#
# Table name: work_item_types
#
#  id                     :bigint           not null, primary key
#  item_level             :integer          default(0), not null
#  name                   :string           not null
#  quality_indicator_type :boolean          default(FALSE), not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  company_id             :integer          not null
#
# Indexes
#
#  index_work_item_types_on_company_id              (company_id)
#  index_work_item_types_on_item_level              (item_level)
#  index_work_item_types_on_quality_indicator_type  (quality_indicator_type)
#
# Foreign Keys
#
#  fk_rails_8c3c9d6119  (company_id => companies.id)
#
class WorkItemType < ApplicationRecord
  belongs_to :company
end
