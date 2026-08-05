class DownloadsController < ApplicationController
  before_action :set_regist_by_token,
                only: %i[
                  show
                  file
                  subscribe
                  unsubscribe
                ]

  # 1冊目のダウンロード画面
  def show
    @download_file = DownloadFile.find_by(
      volume: 1,
      published: true
    )

    return if @download_file.present?

    redirect_to(
      root_path,
      alert: "公開中のダウンロードファイルがありません。"
    )
  end

  # 1冊目の実ダウンロード
  def file
    download_file = DownloadFile.find_by(
      id: params[:download_file_id],
      volume: 1,
      published: true
    )

    unless download_file
      redirect_to(
        download_path(@regist.token),
        alert: "ダウンロードファイルが見つかりません。"
      )
      return
    end

    process_download!(
      regist: @regist,
      download_file: download_file,
      redirect_path: download_path(@regist.token)
    )
  rescue ActiveRecord::RecordInvalid,
         ActiveRecord::RecordNotSaved => e
    log_download_error(
      label: "Download record error",
      error: e
    )

    redirect_to(
      download_path(@regist.token),
      alert: "ダウンロード履歴の保存に失敗しました。"
    )
  rescue StandardError => e
    log_download_error(
      label: "Download error",
      error: e
    )

    redirect_to(
      download_path(@regist.token),
      alert: "ダウンロード処理に失敗しました。"
    )
  end

  # メール購読
  def subscribe
    @regist.email_confirmation = @regist.email

    if @regist.update(subscribed: true)
      Rails.logger.info(
        "登録更新成功: #{@regist.inspect}"
      )
    else
      Rails.logger.error(
        "登録更新失敗: " \
        "#{@regist.errors.full_messages.join(', ')}"
      )
    end

    redirect_back fallback_location: root_path
  end

  # メール購読解除
  def unsubscribe
    @regist.email_confirmation = @regist.email

    if @regist.update(subscribed: false)
      Rails.logger.info("登録解除成功")
    else
      Rails.logger.error(
        "登録解除失敗: " \
        "#{@regist.errors.full_messages.join(', ')}"
      )
    end

    redirect_back fallback_location: root_path
  end

  # 2冊目のダウンロード画面
  def second
    @regist = Regist.find_by(
      second_token: params[:token]
    )

    unless @regist
      render(
        plain: "無効なリンクです",
        status: :not_found
      )
      return
    end

    @download_file = DownloadFile.find_by(
      volume: 2,
      published: true
    )

    return if @download_file.present?

    redirect_to(
      root_path,
      alert: "公開中の2冊目のファイルがありません。"
    )
  end

  # 2冊目の実ダウンロード
  def second_file
    @regist = Regist.find_by(
      second_token: params[:token]
    )

    unless @regist
      redirect_to(
        root_path,
        alert: "無効なダウンロードURLです。"
      )
      return
    end

    download_file = DownloadFile.find_by(
      id: params[:download_file_id],
      volume: 2,
      published: true
    )

    unless download_file
      redirect_to(
        second_download_path(@regist.second_token),
        alert: "2冊目のダウンロードファイルが見つかりません。"
      )
      return
    end

    process_download!(
      regist: @regist,
      download_file: download_file,
      redirect_path:
        second_download_path(@regist.second_token)
    )
  rescue ActiveRecord::RecordInvalid,
         ActiveRecord::RecordNotSaved => e
    log_download_error(
      label: "Second download record error",
      error: e
    )

    redirect_to(
      second_download_path(@regist.second_token),
      alert: "ダウンロード履歴の保存に失敗しました。"
    )
  rescue StandardError => e
    log_download_error(
      label: "Second download error",
      error: e
    )

    redirect_to(
      second_download_path(@regist.second_token),
      alert: "ダウンロード処理に失敗しました。"
    )
  end

  private

  # 1冊目のtokenから予約者を取得
  def set_regist_by_token
    @regist = Regist.find_by(
      token: params[:token]
    )

    return if @regist.present?

    redirect_to(
      root_path,
      alert: "データが見つかりません。"
    )
  end

  # ファイル確認・カウント・ログ保存・ファイル送信
  def process_download!(
    regist:,
    download_file:,
    redirect_path:
  )
    file_path = absolute_file_path(download_file)

    Rails.logger.info(
      "[Download] " \
      "download_file_id=#{download_file.id}, " \
      "regist_id=#{regist.id}, " \
      "volume=#{download_file.volume}, " \
      "db_path=#{download_file.path}, " \
      "absolute_path=#{file_path}, " \
      "exists=#{File.file?(file_path)}, " \
      "readable=#{File.readable?(file_path)}"
    )

    unless File.file?(file_path)
      Rails.logger.error(
        "[Download file missing] " \
        "download_file_id=#{download_file.id}, " \
        "path=#{file_path}"
      )

      redirect_to(
        redirect_path,
        alert: "ファイルが存在しません。"
      )
      return
    end

    unless File.readable?(file_path)
      Rails.logger.error(
        "[Download file unreadable] " \
        "download_file_id=#{download_file.id}, " \
        "path=#{file_path}"
      )

      redirect_to(
        redirect_path,
        alert: "ファイルを読み込めません。"
      )
      return
    end

    unless regist_downloadable?(
      regist: regist,
      download_file: download_file
    )
      redirect_to(
        redirect_path,
        alert: "ダウンロード上限に達しました。"
      )
      return
    end

    record_download!(
      regist: regist,
      download_file: download_file
    )

    send_file(
      file_path,
      filename: download_file.filename,
      type:
        download_file.content_type.presence ||
        "application/pdf",
      disposition: "attachment"
    )
  end

  # DBのpathから実ファイルの絶対パスを作成
  def absolute_file_path(download_file)
    Rails.root.join(
      "public",
      download_file.path.to_s.delete_prefix("/")
    )
  end

  # 予約者ごとのダウンロード上限判定
  def regist_downloadable?(regist:, download_file:)
    download_limit =
      download_file.download_limit.presence || 10

    if download_file.volume.to_i == 2
      regist.second_download_count.to_i <
        download_limit.to_i
    else
      regist.download_count.to_i <
        download_limit.to_i
    end
  end

  # カウント更新とログ登録を同じトランザクションで実行
  def record_download!(regist:, download_file:)
    ActiveRecord::Base.transaction do
      # 同時押下時のカウントずれを防止
      regist.lock!
      download_file.lock!

      # lock後の最新値でもう一度上限を確認
      unless regist_downloadable?(
        regist: regist,
        download_file: download_file
      )
        regist.errors.add(
          :base,
          "ダウンロード上限に達しています。"
        )

        raise ActiveRecord::RecordInvalid,
              regist
      end

      increment_regist_download_count!(
        regist: regist,
        volume: download_file.volume
      )

      download_file.increment!(
        :download_count
      )

      DownloadLog.create!(
        download_file: download_file,
        regist: regist,
        downloaded_at: Time.current,
        ip_address: request.remote_ip,
        user_agent:
          request.user_agent.to_s.truncate(65_535)
      )
    end
  end

  # 1冊目・2冊目で予約者側のカラムを分けて加算
  def increment_regist_download_count!(
    regist:,
    volume:
  )
    if volume.to_i == 2
      regist.increment!(
        :second_download_count
      )
    else
      regist.increment!(
        :download_count
      )
    end
  end

  # エラー内容をproduction.logと専用ログへ記録
  def log_download_error(label:, error:)
    error_message =
      "[#{label}]\n" \
      "class=#{error.class}\n" \
      "message=#{error.message}\n" \
      "regist_id=#{@regist&.id}\n" \
      "download_file_id=#{params[:download_file_id]}\n" \
      "#{error.backtrace&.first(20)&.join("\n")}"

    Rails.logger.error(error_message)

    File.open(
      Rails.root.join(
        "log",
        "download_error.log"
      ),
      "a"
    ) do |file|
      file.puts
      file.puts "----------------------------------------"
      file.puts Time.current
      file.puts error_message
    end
  rescue StandardError => log_error
    Rails.logger.error(
      "[Download error log failure] " \
      "#{log_error.class}: #{log_error.message}"
    )
  end
end