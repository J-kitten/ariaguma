# app/models/user.rb
class User < ApplicationRecord
  has_secure_password

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true
  validates :password, presence: true, length: { minimum: 6 }, if: -> { new_record? || !password.nil? }

  before_validation :set_email_hash

  def set_email_hash
    if email.present? && will_save_change_to_email?
      self.email_hash = Digest::SHA256.hexdigest(email.to_s.downcase.strip)
    end
  end

  # クラスメソッド: ハッシュされたメールでユーザーを検索
  def self.find_by_email_hash(email)
    hashed = Digest::SHA256.hexdigest(email.to_s.downcase.strip)
    find_by(email_hash: hashed)
  end

end

