class CreateTags < ActiveRecord::Migration
  def change
    create_table :tags do |t|
      t.text :name
      t.integer :id

      t.timestamps
    end
  end
end
