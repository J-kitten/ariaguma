class RemoveMessageFromRegists < ActiveRecord::Migration[7.1]
  def change
    remove_column :regists, :message, :text
  end
end
