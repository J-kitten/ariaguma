class AddSecondTokenToRegists < ActiveRecord::Migration[8.0]
  def change
    add_column :regists, :second_token, :string, limit: 50
  end
end
