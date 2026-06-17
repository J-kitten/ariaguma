class AddForeignKeyToRegistsUserId < ActiveRecord::Migration[7.1]
  def change
    add_foreign_key :regists, :users
  end
end
