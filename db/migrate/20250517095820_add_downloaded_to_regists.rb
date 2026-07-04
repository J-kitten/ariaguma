class AddDownloadedToRegists < ActiveRecord::Migration[8.0]
  def change
    add_column :regists, :downloaded, :integer, default: 0
  end
end
