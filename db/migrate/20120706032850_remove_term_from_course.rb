class RemoveTermFromCourse < ActiveRecord::Migration
  def up
    remove_column :courses, :term
      end

  def down
    add_column :courses, :term, :string
  end
end
