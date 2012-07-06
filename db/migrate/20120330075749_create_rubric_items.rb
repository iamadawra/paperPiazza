class CreateRubricItems < ActiveRecord::Migration
  def change
    create_table :rubric_items do |t|
      t.text :title
      t.text :description
      t.decimal :weight, :precision => 10, :scale => 4
      t.integer :question_id

      t.timestamps
    end
  end
end
