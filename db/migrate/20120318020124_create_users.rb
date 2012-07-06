class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :name
      t.string :email
      t.string :password_digest

      t.timestamps
    end

    # Ensure uniqueness is handled at the DB level for race conditions.
    add_index :users, :email, unique: true

  end
end
