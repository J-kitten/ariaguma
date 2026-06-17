class RemoveEmailHashFromContacts < ActiveRecord::Migration[8.0]
  def change
    remove_column :contacts, :email_hash, :string
  end
end
