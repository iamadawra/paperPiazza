class AddPasswordResetToUsers < ActiveRecord::Migration
  def change
    add_column :users, :perishable_token, :string

    add_column :users, :password_reset_sent_at, :datetime

  end
end
