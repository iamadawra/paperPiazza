class AddAuthorIdsToCourse < ActiveRecord::Migration
  def change
    add_column :courses, :author_ids, :text

  end
end
