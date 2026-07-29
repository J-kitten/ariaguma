class DownloadFile < ApplicationRecord
  validates :name,
            presence: true,
            length: { maximum: 100 }

  validates :filename,
            presence: true,
            length: { maximum: 255 }

  validates :path,
            presence: true,
            uniqueness: true,
            length: { maximum: 500 }

  validates :volume,
            presence: true,
            numericality: {
              only_integer: true,
              greater_than_or_equal_to: 0,
              less_than_or_equal_to: 255
            }

  validates :file_size,
            numericality: {
              only_integer: true,
              greater_than_or_equal_to: 0
            },
            allow_nil: true

  validates :download_limit,
            presence: true,
            numericality: {
              only_integer: true,
              greater_than_or_equal_to: 0
            }

  validates :download_count,
            presence: true,
            numericality: {
              only_integer: true,
              greater_than_or_equal_to: 0
            }

  validates :sort_order,
            presence: true,
            numericality: {
              only_integer: true
            }

  scope :published_files, -> {
    where(published: true).order(:sort_order, :id)
  }
  has_many :download_logs,
           dependent: :destroy

  def downloadable?
    published? &&
      File.file?(absolute_file_path) &&
      (download_limit.zero? || download_count < download_limit)
  end

  def absolute_file_path
    Rails.root.join("public", path.delete_prefix("/"))
  end

  def file_size_text
    return "-" if file_size.blank?

    ActiveSupport::NumberHelper.number_to_human_size(file_size)
  end

end
