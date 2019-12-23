# frozen_string_literal: true

class RemoveLastCompanyVisitedFromUser < ActiveRecord::Migration[6.0]
  def change
    remove_column :users, :last_company_id, :integer
  end
end
