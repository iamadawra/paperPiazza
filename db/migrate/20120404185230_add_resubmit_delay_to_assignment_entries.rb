class AddResubmitDelayToAssignmentEntries < ActiveRecord::Migration
  def change
    add_column :assignment_entries, :resubmit_delay, :integer
  end
end
