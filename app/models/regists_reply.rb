class RegistsReply < ApplicationRecord

  belongs_to :regist  # 外部キー regists.id を参照する場合

  validates :message, length: { maximum: 5000 }



end
