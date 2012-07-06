class CreateLectures < ActiveRecord::Migration
  def change
    create_table :lectures do |t|
      t.string :title
      t.string :video_url
      t.string :slides_url
      t.integer :number
      t.datetime :release_date
      t.integer :course_id
      t.integer :video_duration

      t.timestamps
    end
  end
end
