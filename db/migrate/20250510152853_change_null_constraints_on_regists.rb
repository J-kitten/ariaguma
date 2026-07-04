class ChangeNullConstraintsOnRegists < ActiveRecord::Migration[8.0]
  def change
    change_column_null :regists, :name, false
    change_column_null :regists, :token, false
    change_column_null :regists, :email_hash, false
  end
end
