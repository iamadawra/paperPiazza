class AddConferenceToCourse < ActiveRecord::Migration
  def change
    add_column :courses, :conference, :string

  end
end
