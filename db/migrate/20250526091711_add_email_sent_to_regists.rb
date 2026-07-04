class AddEmailSentToRegists < ActiveRecord::Migration[7.1]
  def change
    add_column :regists, :email_sent_01, :string, default: '未送信'
    add_column :regists, :email_sent_02, :string, default: '未送信'
  end
end
