class CreateRegistsReplies < ActiveRecord::Migration[7.1]
  def change
    create_table :regists_replies do |t|
      t.string :name, limit: 50
      t.string :subject, limit: 50
      t.string :email_hash, limit: 255
      t.text :message
      t.integer :regist_id

      t.timestamps  # created_at, updated_at を自動で追加
    end
  end
end

