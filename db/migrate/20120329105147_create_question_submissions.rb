class CreateQuestionSubmissions < ActiveRecord::Migration
  def change
    create_table :question_submissions do |t|
      t.boolean :graded
      t.decimal :score, precision: 10, scale: 4, default: nil
      t.text    :answer

      t.references :question
      t.references :user

      t.timestamps
    end
  end
end
