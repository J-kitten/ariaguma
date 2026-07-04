class AddTrashToReplies < ActiveRecord::Migration[8.0]
  def change
    add_column :replies, :trash, :boolean
  end
end
