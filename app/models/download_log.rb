# app/models/download_log.rb

class DownloadLog < ApplicationRecord
  belongs_to :download_file
  belongs_to :regist, optional: true

  validates :downloaded_at,
            presence: true

end
