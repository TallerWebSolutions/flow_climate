class AddMembershipEffortPercentageToDemandEffort < ActiveRecord::Migration[7.0]
  def change
    add_column :demand_efforts, :membership_effort_percentage, :decimal
  end
end
