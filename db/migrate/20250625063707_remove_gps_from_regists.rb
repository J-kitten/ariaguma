class RemoveGpsFromRegists < ActiveRecord::Migration[7.1]
  def change
    remove_column :regists, :gps, :string
  end
end
