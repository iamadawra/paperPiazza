class CreateAssignments < ActiveRecord::Migration
  def change
    create_table :assignments do |t|
      t.string :title
      t.datetime :release_date
      t.datetime :due_date
      t.decimal :total_points, :precision => 10, :scale => 4, :default => 0.0
      t.integer :course_id

      t.timestamps
    end
  end
end
