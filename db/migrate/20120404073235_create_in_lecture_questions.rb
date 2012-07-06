class CreateInLectureQuestions < ActiveRecord::Migration
  def change
    create_table :in_lecture_questions do |t|

      t.references :lecture,  :null => false 
      t.references :question, :null => false 

      t.integer    :hours,   :null => false, :default => 0
      t.integer    :minutes, :null => false, :default => 0
      t.integer    :seconds, :null => false, :default => 0

      t.timestamps
    end
  end
end
