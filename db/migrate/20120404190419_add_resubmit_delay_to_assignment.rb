class AddResubmitDelayToAssignment < ActiveRecord::Migration
  def change
    add_column :assignments, :resubmit_delay, :integer

  end
end
