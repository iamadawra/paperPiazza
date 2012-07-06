class CreateCourseMemberships < ActiveRecord::Migration
  def change
    create_table :course_memberships do |t|
      t.references :course, :null => false
      t.references :user, :null => false

      # Store the role as a byte
      t.integer    :role, :limit => 1, :null => false

      t.timestamps
    end

    add_index :course_memberships, :course_id
    add_index :course_memberships, :user_id

    # Ensure uniqueness is handled at the DB level for race conditions.
    add_index :course_memberships, [:course_id, :user_id], unique: true 
  end
end
