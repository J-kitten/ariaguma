class DownloadsController < ApplicationController
#  before_action :set_regist
  before_action :set_regist_by_token, only: [:show, :subscribe, :unsubscribe]

  MAX_DOWNLOADS = 50

  def show
    @regist = Regist.find_by(token: params[:token])
    unless @regist
      redirect_to root_path, admin_alert: '無効なトークン'
    end
#    if @regist.nil?
#      redirect_to root_path, admin_alert: "無効なトークンです"
#    elsif @regist.downloaded >= MAX_DOWNLOADS
#      render plain: "ダウンロード可能回数を超えました。"
#    else
#      # ダウンロードページのビューを表示（言語チェックボックス等）
#      render :show
#    end
  end

  def download_files
    file_path = Rails.root.join("public", "downloads", "Deadly_Battle_with_the_Phantom_Demon_ja.zip")

    if File.exist?(file_path)
      logger.debug ">>> ファイル送信準備OK"
      file_data = File.binread(file_path)
      send_data file_data,
                filename: "Deadly_Battle_with_the_Phantom_Demon_ja.zip",
                type: "application/zip",
                disposition: "attachment"
      return
    else
      logger.debug ">>> ファイルが存在しません"
      render plain: "ファイルが存在しません", status: :not_found
    end
  end

  def file
    @regist = Regist.find_by(token: params[:token])
    unless @regist
      head :not_found and return
    end

    if @regist.downloaded < MAX_DOWNLOADS
      redirect_to download_path(@regist.token), admin_alert: "ダウンロード上限に達しました。"
      #render plain: "ダウンロード上限に達しています", status: :forbidden and return

    end

    # ダウンロード回数を加算
    @regist.increment!(:downloaded)

    # ダウンロードファイルのパス
    filename = params[:filename]
    file_path = Rails.root.join("public", "downloads", "#{filename}.zip")

    Rails.logger.debug ">>>>>> 送信ファイル: #{file_path}"
    Rails.logger.debug "ファイルパス: #{file_path}"
    Rails.logger.debug "ファイル存在?: #{File.exist?(file_path)}"

    unless File.exist?(file_path)
      render plain: "ファイルが存在しません", status: :not_found and return
    end

    # ファイルを送信
    send_file file_path,
              filename: "#{filename}.zip",
              type: "application/zip",
              disposition: "attachment"
  end

  # 「要る」ボタンが押されたとき（subscribed を true に更新）
  def subscribe
    set_regist_by_token
    @regist.update(subscribed: true)
    @regist.email_confirmation = @regist.email
    if @regist.update(subscribed: true)
      Rails.logger.info "登録更新成功: #{@regist.inspect}"
    else
      Rails.logger.error "登録更新失敗: #{@regist.errors.full_messages}"
    end

    #respond_to do |format|
    #  format.html { redirect_to download_path(@regist.token), notice: "登録されました" }
    #  format.json { render json: { status: "OK", subscribed: true } }
    #end

  end

  # 「要らない」ボタンが押されたとき（subscribed を false に更新）
  def unsubscribe
    set_regist_by_token
    @regist.email_confirmation = @regist.email
    if @regist.update(subscribed: false)
      Rails.logger.info "登録解除成功"
    else
      Rails.logger.error "登録解除失敗: #{@regist.errors.full_messages}"
    end

    #respond_to do |format|
    #  format.html { redirect_to download_path(@regist.token), notice: "登録解除されました" }
    #  format.json { render json: { status: "ok", subscribed: false } }
    #end

  end

  def second  # 2冊目をdownload する
    @regist = Regist.find_by(second_token: params[:token])

    if @regist.nil?
      render plain: "無効なリンクです", status: :not_found
      return
    end

    # 必要であればログ記録や、DL済みのフラグ更新など
  end


  private

  def set_regist_by_token
    @regist = Regist.find_by(token: params[:token]) 
    logger.warn(">>>>> def set_regist")
    logger.warn("Regist.find_by(token: params[:token] #{Regist.find_by(token: params[:token])}")
    #unless @regist
      redirect_to root_path, admin_alert: "データが見つかりません" unless @regist
    #end
  end
end
