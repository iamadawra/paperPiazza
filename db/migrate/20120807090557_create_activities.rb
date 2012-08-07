class CreateActivities < ActiveRecord::Migration
  def change
    create_table :activities do |t|
      t.integer :user_id
      t.integer :course_id
      t.datetime :time
      t.string :action

      t.timestamps
    end
  end
end
