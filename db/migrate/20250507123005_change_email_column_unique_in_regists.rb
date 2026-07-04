class ChangeEmailColumnUniqueInRegists < ActiveRecord::Migration[8.0]
  def change
    change_column_null :regists, :email, false

    unless index_exists?(:regists, :email, name: "index_regists_on_email")
      add_index :regists, :email, unique: true, length: 255
    end
  end
end

