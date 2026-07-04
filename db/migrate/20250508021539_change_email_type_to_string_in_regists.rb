# db/migrate/xxxxxx_change_email_type_to_string_in_regists.rb
class ChangeEmailTypeToStringInRegists < ActiveRecord::Migration[7.1] # ←ご使用のRailsバージョンに合わせてください
  def change
    change_column :regists, :email, :string, limit: 255
  end
end

