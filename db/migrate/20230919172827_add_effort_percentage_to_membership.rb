class AddEffortPercentageToMembership < ActiveRecord::Migration[7.0]
  def change
    add_column :memberships, :effort_percentage, :decimal
  end
end
