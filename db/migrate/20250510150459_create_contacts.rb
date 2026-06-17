class CreateContacts < ActiveRecord::Migration[8.0]
  def change
    create_table :contacts do |t|
      t.string :name, limit: 50, null: false
      t.string :subject, limit: 50, null: false
      t.string :email, limit: 255, null: false
      t.string :email_hash, limit: 255
      t.text :message, null: false

      t.timestamps
    end

    add_index :contacts, :email, unique: false  # 重複OK
    add_index :contacts, :email_hash, unique: false  # 検索高速化用

  end
end
