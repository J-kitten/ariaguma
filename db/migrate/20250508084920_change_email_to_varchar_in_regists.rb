class ChangeEmailToVarcharInRegists < ActiveRecord::Migration[8.0]
  def change
    change_column :regists, :email, :string, limit: 255
  end
end
