class ChangeEmailColumnLengthInUsers < ActiveRecord::Migration[7.1]
  def change
    change_column :regists, :email, :string, limit: 255
  end
end
