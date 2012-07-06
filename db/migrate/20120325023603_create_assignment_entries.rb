class CreateAssignmentEntries < ActiveRecord::Migration
  def change
    create_table :assignment_entries do |t|
      t.integer :number
      t.integer :assignment_id
      t.integer :question_id
      t.decimal :points, :precision => 10, :scale => 4, :default => 0.0

      t.timestamps
    end
  end
end
