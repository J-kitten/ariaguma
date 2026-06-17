class AddUniqueIndexToEmailInRegists < ActiveRecord::Migration[8.0]
  def change
    change_column_null :regists, :email, false
    remove_index :regists, :email if index_exists?(:regists, :email)
    add_index :regists, :email, unique: true
  end
end
