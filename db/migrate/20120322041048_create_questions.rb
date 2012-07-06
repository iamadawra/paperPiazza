class CreateQuestions < ActiveRecord::Migration
  def change
    create_table :questions do |t|

      # For STI
      t.string :type, :limit => 100

      # Standard fields
      t.text    :text
      t.text    :choices
      t.text    :answers
      t.text    :explanations

      # To support question groups
      t.integer :parent_id
      t.integer :child_index
      t.decimal :weight, :precision => 10, :scale => 4, :default => 1

      t.text   :json
      t.text   :raw_source
      t.string :raw_source_format

      # For JavaScript questions
      t.text :javascript_includes
      t.text :parameters

      t.timestamps
    end

    add_index :questions, :parent_id

  end
end
