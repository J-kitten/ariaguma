# app/models/reply.rb
class Reply < ApplicationRecord

  attribute :email_hash, :string

  # バリデーション
  validates :subject, :email_hash, :message, presence: true
  validates :subject, length: { maximum: 50 }
  validates :email_hash, length: { maximum: 255 }, confirmation: true
  validates :message, length: { maximum: 5000 } # 必要に応じて制限

  private


end
