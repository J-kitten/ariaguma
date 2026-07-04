class AddTrashToContacts < ActiveRecord::Migration[7.1]
  def change
    add_column :contacts, :trash, :boolean
    add_column :contacts, :read, :boolean
  end
end
