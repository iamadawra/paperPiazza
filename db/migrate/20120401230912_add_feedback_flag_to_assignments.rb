class AddFeedbackFlagToAssignments < ActiveRecord::Migration
  def change
    add_column :assignments, :feedback, :boolean, :default => false
  end
end
