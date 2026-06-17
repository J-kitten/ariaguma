class ChangeEmailHashNullOnContacts < ActiveRecord::Migration[8.0]
  def change
    change_column_null :contacts, :email_hash, false
  end
end
