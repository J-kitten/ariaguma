# app/models/regist.rb
require 'digest'

class Regist < ApplicationRecord
  before_validation :set_email_hash

  # 仮想属性（DBに保存しないがフォームから受け取る）
  attr_accessor :email_confirmation
  attr_accessor :reply_subject, :reply_body

  encrypts :email

  FIRST_DOWNLOAD_LIMIT = 50
  SECOND_DOWNLOAD_LIMIT = 50

  validates :name, presence: true, length: { maximum: 50 }
  validates :email, presence: true, length: { maximum: 100 }
  validates :email_confirmation, presence: true, on: :create, length: { maximum: 100 }
  validate :email_matches_confirmation, on: :create
  validates :email_hash, uniqueness: { message: "はすでに登録されています。" }
  validate :copy_email_hash_error_to_email

  # 返信用（仮想属性）
  validates :reply_subject, presence: { message: "件名を入力してください" }, if: :replying?
  validates :reply_body, presence: { message: "本文を入力してください" }, if: :replying?

  after_create :send_download_email

  has_many :download_logs,
           dependent: :nullify

  belongs_to :regist, optional: true

  private

  def replying?
    reply_subject.present? || reply_body.present?
  end

  def set_email_hash
    if email.present? && will_save_change_to_email?
      self.email_hash = Digest::SHA256.hexdigest(email.to_s.downcase.strip)
    end
  end

  def email_matches_confirmation
    if email.present? && email_confirmation.present? && email != email_confirmation
      errors.add(:email_confirmation, "が一致していません")
      errors.add(:email, "と確認用メールアドレスが一致していません") # ←追加
    end
  end

  def copy_email_hash_error_to_email
    if errors[:email_hash].any? && errors[:email].blank?
      errors.add(:email, errors[:email_hash].first)
    end
  end

  # 
  def send_download_email
    RegistMailer.download_email(self).deliver_later

    Reply.create!(
      name: self.name,
      subject: 'Present『死闘の使命』電子書籍の予約完了通知（自動）',
      email_hash: self.email_hash,
      message: "ダウンロードURLメールの予約を受け付け、予約者からの登録データをDBに保存しました（#{Time.current.strftime('%Y/%m/%d %H:%M:%S')}）",
      regist_id: self.id
    )

    # 1通目のメールの送信日時をregist.email_sent_01に保存
    #self.update_column(:email_sent_01, Time.current)
  end

  def first_downloadable?
    download_count.to_i < FIRST_DOWNLOAD_LIMIT
  end

  def second_downloadable?
    second_download_count.to_i < SECOND_DOWNLOAD_LIMIT
  end

  def first_remaining_download_count
    [
      FIRST_DOWNLOAD_LIMIT -
        download_count.to_i,
      0
    ].max
  end

  def second_remaining_download_count
    [
      SECOND_DOWNLOAD_LIMIT -
        second_download_count.to_i,
      0
    ].max
  end

end
