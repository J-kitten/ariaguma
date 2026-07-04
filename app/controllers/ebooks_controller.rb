class EbooksController < ApplicationController
  def download
    # DB更新（例：ログインユーザーのカウンタ増加）
    current_user&.increment!(:ebook_download_count)

    filename = params[:filename]
    filepath = Rails.root.join("public", "ebooks", filename)

    if File.exist?(filepath)
      send_file(
        filepath,
        filename: filename,
        disposition: "attachment"  # ダウンロードを強制
      )
    else
      render plain: "ファイルが見つかりません", status: :not_found
    end
  end
end

