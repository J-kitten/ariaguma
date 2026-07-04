class AddEmailHashToRegists < ActiveRecord::Migration[8.0]
  def change
    unless column_exists?(:regists, :email_hash)
      add_column :regists, :email_hash, :string
    end
  end
end
