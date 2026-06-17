class AddEmailHashToRegists < ActiveRecord::Migration[8.0]
  def change
    add_column :regists, :email_hash, :string
    add_index :regists, :email_hash, unique: true
  end
end
