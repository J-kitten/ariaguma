class ChangeNullConstraintsOnContacts < ActiveRecord::Migration[8.0]
  def change
    change_column_null :contacts, :name, false
    change_column_null :contacts, :subject, false
    change_column_null :contacts, :email, false
    change_column_null :contacts, :message, false
  end
end
