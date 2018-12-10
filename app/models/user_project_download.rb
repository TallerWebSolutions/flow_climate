# frozen_string_literal: true

# == Schema Information
#
# Table name: user_project_downloads
#
#  created_at          :datetime         not null
#  first_id_downloaded :integer          not null, indexed
#  id                  :bigint(8)        not null, primary key
#  last_id_downloaded  :integer          not null, indexed
#  project_id          :integer          not null, indexed
#  updated_at          :datetime         not null
#  user_id             :integer          not null, indexed
#
# Indexes
#
#  index_user_project_downloads_on_first_id_downloaded  (first_id_downloaded)
#  index_user_project_downloads_on_last_id_downloaded   (last_id_downloaded)
#  index_user_project_downloads_on_project_id           (project_id)
#  index_user_project_downloads_on_user_id              (user_id)
#
# Foreign Keys
#
#  fk_rails_0f08531a34  (user_id => users.id)
#  fk_rails_626b44cbc6  (project_id => projects.id)
#

class UserProjectDownload < ApplicationRecord
  belongs_to :user
  belongs_to :project

  validates :user, :project, :first_id_downloaded, :last_id_downloaded, presence: true
end
