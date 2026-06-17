class RemoveUserIdFromRegists < ActiveRecord::Migration[7.1]
  def change
    remove_foreign_key :regists, :users
    remove_column :regists, :user_id, :bigint
  end
end
