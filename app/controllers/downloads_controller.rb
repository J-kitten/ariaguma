class DownloadsController < ApplicationController
  before_action :set_regist_by_token,
                only: %i[
                  show
                  file
                  subscribe
                  unsubscribe
                ]

  before_action :require_firebase_login,
                only: %i[
                  show
                  file
                  subscribe
                  unsubscribe
                ]

  before_action :set_regist_by_second_token,
                only: %i[
                  second
                ]

  before_action :require_matching_firebase_user,
                only: %i[
                  show
                  file
                  subscribe
                  unsubscribe
                  second
                  second_file
                ]


  # ****************************************
  # 1冊目
  # ****************************************

  # トークン付きURLから最初にアクセス
  #
  # /download/:token
  #
  # 本人確認後、予約者IDをsessionへ保存して、
  # tokenをURLから消す。
  def show
    @download_file = DownloadFile.find_by(
      volume: 1,
      published: true
    )

    unless @download_file
      redirect_to(
        root_path,
        alert: "公開中のダウンロードファイルがありません。"
      )
      return
    end

    # tokenそのものではなくRegistのIDをsessionへ保存
    session[:download_regist_id] = @regist.id

    # URLからtokenを消す
    redirect_to download_index_path(open: 1)
  end


  # tokenをアドレスバーから消した後の
  # ダウンロード画面
  #
  # /download?open=1
  def show_from_session
    unless params[:open] == "1"
      redirect_to root_path,
                  alert: "無効なダウンロードURLです。"
      return
    end

    # Railsログイン確認
    if session[:user_id].blank? ||
       session[:email_hash].blank?

      redirect_to(
        root_path(open_login: "1"),
        alert: "ダウンロードするにはログインしてください。"
      )
      return
    end

    regist_id = session[:download_regist_id]

    if regist_id.blank?
      redirect_to(
        root_path,
        alert: "ダウンロード情報が見つかりません。"
      )
      return
    end

    @regist = Regist.find_by(
      id: regist_id
    )

    unless @regist
      session.delete(:download_regist_id)

      redirect_to(
        root_path,
        alert: "ダウンロード情報が見つかりません。"
      )
      return
    end

    # ログインユーザーとtoken所有者が同じか確認
    unless secure_email_hash_match?(
      session[:email_hash].to_s,
      @regist.email_hash.to_s
    )
      session.delete(:download_regist_id)

      redirect_to(
        mypage_path,
        alert:
          "このダウンロードURLは、現在ログイン中のユーザーには使用できません。"
      )
      return
    end

    @download_file = DownloadFile.find_by(
      volume: 1,
      published: true
    )

    unless @download_file
      redirect_to(
        root_path,
        alert: "公開中のダウンロードファイルがありません。"
      )
    end

    # show_from_session.html.erb ではなく
    # 既存の downloads/show.html.erb を表示する
    render :show
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
        download_index_path(open: 1),
        alert: "ダウンロードファイルが見つかりません。"
      )
      return
    end

    process_download!(
      regist: @regist,
      download_file: download_file,
      redirect_path: download_index_path(open: 1)
    )

  rescue ActiveRecord::RecordInvalid,
         ActiveRecord::RecordNotSaved => e

    log_download_error(
      label: "Download record error",
      error: e
    )

    redirect_to(
      download_index_path(open: 1),
      alert: "ダウンロード履歴の保存に失敗しました。"
    )

  rescue StandardError => e

    log_download_error(
      label: "Download error",
      error: e
    )

    redirect_to(
      download_index_path(open: 1),
      alert: "ダウンロード処理に失敗しました。"
    )
  end


  # ****************************************
  # メール購読
  # ****************************************

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


  # ****************************************
  # 2冊目
  # ****************************************

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

    unless @download_file
      redirect_to(
        root_path,
        alert: "公開中の2冊目のファイルがありません。"
      )
      return
    end

    # ----------------------------------------
    # sessionへ保存
    # ----------------------------------------

    session[:second_download_regist_id] = @regist.id

    # tokenをURLから消す
    redirect_to second_download_index_path(open: 1)
  end

  def second_file
    regist_id =
      session[:second_download_regist_id]

    if regist_id.blank?
      redirect_to(
        root_path,
        alert: "ダウンロード情報が見つかりません。"
      )
      return
    end

    @regist =
      Regist.find_by(id: regist_id)

    unless @regist
      session.delete(
        :second_download_regist_id
      )

      redirect_to(
        root_path,
        alert: "無効なダウンロード情報です。"
      )
      return
    end

    unless secure_email_hash_match?(
      session[:email_hash].to_s,
      @regist.email_hash.to_s
    )
      redirect_to(
        mypage_path,
        alert:
          "このダウンロードURLは、現在ログイン中のユーザーには使用できません。"
      )
      return
    end

    download_file =
      DownloadFile.find_by(
        id: params[:download_file_id],
        volume: 2,
        published: true
      )

    unless download_file
      redirect_to(
        second_download_index_path(open: 1),
        alert:
          "2冊目のダウンロードファイルが見つかりません。"
      )
      return
    end

    process_download!(
      regist: @regist,
      download_file: download_file,
      redirect_path:
        second_download_index_path(open: 1)
    )

  rescue ActiveRecord::RecordInvalid,
         ActiveRecord::RecordNotSaved => e

    log_download_error(
      label: "Second download record error",
      error: e
    )

    redirect_to(
      second_download_index_path(open: 1),
      alert: "ダウンロード履歴の保存に失敗しました。"
    )

  rescue StandardError => e

    log_download_error(
      label: "Second download error",
      error: e
    )

    redirect_to(
      second_download_index_path(open: 1),
      alert: "ダウンロード処理に失敗しました。"
    )
  end

  # tokenを消した後の2冊目画面
  # /download/second_download?open=1
  def second_from_session
    Rails.logger.info "===== second_from_session ====="
    Rails.logger.info "params = #{params.inspect}"
    Rails.logger.info "session[:second_download_regist_id] = #{session[:second_download_regist_id]}"
    Rails.logger.info "session[:user_id] = #{session[:user_id]}"
    Rails.logger.info "session[:email_hash] = #{session[:email_hash]}"

    unless params[:open] == "1"
      Rails.logger.info "open parameter NG"

      redirect_to root_path,
                  alert: "無効なダウンロードURLです。"
      return
    end

    regist_id =
      session[:second_download_regist_id]

    if regist_id.blank?
      redirect_to(
        root_path,
        alert: "ダウンロード情報が見つかりません。"
      )
      return
    end

    @regist =
      Regist.find_by(id: regist_id)

    unless @regist
      session.delete(
        :second_download_regist_id
      )

      redirect_to(
        root_path,
        alert: "ダウンロード情報が見つかりません。"
      )
      return
    end

    unless secure_email_hash_match?(
      session[:email_hash].to_s,
      @regist.email_hash.to_s
    )
      session.delete(
        :second_download_regist_id
      )

      redirect_to(
        mypage_path,
        alert:
          "このダウンロードURLは現在ログイン中のユーザーには使用できません。"
      )
      return
    end

    @download_file = DownloadFile.find_by(
      volume: 2,
      published: true
    )

    unless @download_file
      redirect_to(
        root_path,
        alert: "公開中の2冊目のファイルがありません。"
      )
      return
    end

    # 既存ビューを表示
    render :second
  end

  private


  # ****************************************
  # 1冊目tokenから予約者取得
  # ****************************************

  def set_regist_by_token
    @regist = Regist.find_by(
      token: params[:token]
    )

    return if @regist.present?

    redirect_to(
      root_path,
      alert: "無効なダウンロードURLです。"
    )
  end


  # ****************************************
  # 2冊目tokenから予約者取得
  # ****************************************

  def set_regist_by_second_token
    @regist = Regist.find_by(
      second_token: params[:token]
    )

    return if @regist.present?

    redirect_to(
      root_path,
      alert: "無効なダウンロードURLです。"
    )
  end


  # ****************************************
  # Firebase/Railsログイン確認
  # ****************************************

  def require_firebase_login
    return if performed?

    if session[:user_id].blank?
      session[:return_to_after_login] =
        request.fullpath

      redirect_to(
        root_path(open_login: "1"),
        alert:
          "ダウンロードするにはログインしてください。"
      )
      return
    end

    if session[:email_hash].blank?
      reset_session

      session[:return_to_after_login] =
        request.fullpath

      redirect_to(
        root_path(open_login: "1"),
        alert:
          "もう一度ログインしてください。"
      )
      return
    end

    login_email_hash =
      session[:email_hash].to_s

    regist_email_hash =
      @regist.email_hash.to_s

    hashes_match =
      secure_email_hash_match?(
        login_email_hash,
        regist_email_hash
      )

    return if hashes_match

    redirect_to(
      mypage_path,
      alert:
        "このダウンロードURLは、現在ログイン中のユーザーには使用できません。"
    )
  end


  # ****************************************
  # Firebaseログインユーザーと予約者一致確認
  # ****************************************

  def require_matching_firebase_user
    return if performed?
    return if @regist.blank?

    Rails.logger.info "=== require_matching_firebase_user ==="
    Rails.logger.info "session[:user_id]=#{session[:user_id]}"
    Rails.logger.info "session[:email_hash]=#{session[:email_hash]}"
    Rails.logger.info "@regist.id=#{@regist&.id}"
    Rails.logger.info "@regist.email_hash=#{@regist&.email_hash}"

    if session[:user_id].blank? ||
       session[:email_hash].blank?

      session[:return_to_after_login] =
        request.fullpath

      redirect_to(
        root_path(open_login: "1"),
        alert:
          "ダウンロードするにはログインしてください。"
      )
      return
    end

    login_email_hash =
      session[:email_hash].to_s

    regist_email_hash =
      @regist.email_hash.to_s

    unless secure_email_hash_match?(
      login_email_hash,
      regist_email_hash
    )
      redirect_to(
        mypage_path,
        alert:
          "このダウンロードURLは、現在ログイン中のユーザーには使用できません。"
      )
    end
  end


  def secure_email_hash_match?(
    login_hash,
    regist_hash
  )
    return false if login_hash.blank?
    return false if regist_hash.blank?

    return false unless
      login_hash.bytesize ==
      regist_hash.bytesize

    ActiveSupport::SecurityUtils.secure_compare(
      login_hash,
      regist_hash
    )
  end


  # ****************************************
  # ファイル確認・カウント・ログ保存・送信
  # ****************************************

  def process_download!(
    regist:,
    download_file:,
    redirect_path:
  )
    file_path =
      absolute_file_path(download_file)

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


  # ****************************************
  # DB path → 絶対パス
  # Path Traversal防止
  # ****************************************

  def absolute_file_path(download_file)
    Rails.logger.info "++++ absolute_file_path private ++++"

    base_dir = Rails.root.join(
              "private",
              "downloads"
            ).expand_path

    file_path = Rails.root.join(
                "private",
                download_file.path.to_s.delete_prefix("/")
              ).expand_path

    unless file_path.to_s.start_with?(base_dir.to_s + File::SEPARATOR)
      raise SecurityError,
            "Invalid download file path"
    end

    file_path
  end


  # ****************************************
  # ダウンロード上限判定
  # ****************************************

  def regist_downloadable?(
    regist:,
    download_file:
  )
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


  # ****************************************
  # カウント + DownloadLog
  # ****************************************

  def record_download!(
    regist:,
    download_file:
  )
    ActiveRecord::Base.transaction do
      regist.lock!
      download_file.lock!

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


  # ****************************************
  # 予約者側ダウンロード回数加算
  # ****************************************

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


  # ****************************************
  # エラーログ
  # ****************************************

  def log_download_error(
    label:,
    error:
  )
    error_message =
      "[#{label}]\n" \
      "class=#{error.class}\n" \
      "message=#{error.message}\n" \
      "regist_id=#{@regist&.id}\n" \
      "download_file_id=#{params[:download_file_id]}\n" \
      "#{error.backtrace&.first(20)&.join("\n")}"

    Rails.logger.error(
      error_message
    )

    File.open(
      Rails.root.join(
        "log",
        "download_error.log"
      ),
      "a"
    ) do |file|
      file.puts
      file.puts(
        "****************************************"
      )
      file.puts Time.current
      file.puts error_message
    end

  rescue StandardError => log_error
    Rails.logger.error(
      "[Download error log failure] " \
      "#{log_error.class}: " \
      "#{log_error.message}"
    )
  end
end