# app/controllers/management_screen/regists_controller.rb
class ManagementScreen::RegistsController < ManagementScreen::BaseController
  before_action :set_counts, only: [:index, :trash, :unread, :readed, :search, :trash_search, :thread]

  layout 'management'

  PER_PAGE = 10

  def index
    query = params[:query] # 検索クエリ取得

    # ページネーション設定
    page = (params[:page] || 1).to_i
    offset = (page - 1) * PER_PAGE

    # 予約希望者一覧（未削除分）を取得
    base_regists = Regist.where(trash: false).order(created_at: :desc)

    @total_pages = (base_regists.count.to_f / PER_PAGE).ceil
    @current_page = page
    @regists = base_regists.offset(offset).limit(PER_PAGE)

    # 「お問合せあり」判定用にcontactsのemail_hashを取得
    @related_contact_email_hashes = Contact.pluck(:email_hash).uniq
  end

  def search
    query = params[:query]
    @current_page = params[:page].to_i > 0 ? params[:page].to_i : 1
    offset = (@current_page - 1) * PER_PAGE

    if query.present? && query.length > 80
      flash[:alert] = "検索ワードは80文字以内で入力してください。"
      redirect_to management_screen_regists_path(query: query, page: @current_page) and return
    end

    # キーワード検索条件
    all_regists = if query.present?
                    Regist.where("name LIKE ? OR email LIKE ?", "%#{query}%", "%#{query}%")
                         .where(trash: 0)
                         .order(created_at: :desc)
                  else
                    Regist.where(trash: 0).order(created_at: :desc)
                  end

    if params[:unread] == "0" # 未読
      all_regists = all_regists.where(unread: 0)
    end
    if params[:unread] == "1" # 既読
      all_regists = all_regists.where(unread: 1)
    end

    @regists = all_regists.offset(offset).limit(PER_PAGE)

    @related_contact_email_hashes = Contact.pluck(:email_hash).uniq

    @total_count = all_regists.count
    @total_pages = (@total_count.to_f / PER_PAGE).ceil

    render :index
  end

  def show
    @regist = Regist.find(params[:id])
  end

  def thread_detail
    @regist = Regist.find(params[:id])
    respond_to do |format|
      format.html { render :show }
      format.any  { head :not_acceptable }
    end
  end

  def toggle_unread
    @regist = Regist.find(params[:id])
    @regist.update(unread: @regist.unread == 0 ? 1 : 0)
    redirect_to management_screen_regists_path, notice: "既読状態を変更しました"
  end

  def trash
    @current_page = params[:page].to_i > 0 ? params[:page].to_i : 1
    offset = (@current_page - 1) * PER_PAGE

    # ゴミ箱に入っているデータのみ取得
    all_regists = Regist.where(trash: true).order(created_at: :desc)
    #all_contacts = Contact.where(trash: true).order(created_at: :desc)

    @total_pages = (all_regists.count.to_f / PER_PAGE).ceil
    @regists = all_regists.offset(offset).limit(PER_PAGE)

    # 「お問合せあり」判定用にcontactsのemail_hashを取得
    @related_contact_email_hashes = Contact.pluck(:email_hash).uniq
  end
  
  def trash_search
    query = params[:query]
    @current_page = params[:page].to_i > 0 ? params[:page].to_i : 1

    if query.present? && query.length > 80
      flash[:alert] = "検索ワードは80文字以内で入力してください。"
      redirect_to management_screen_regists_path(query: query, page: @current_page) and return
    end

    all_regists = if query.present?
                     Regist.where(trash: true)
                           .where("name LIKE ? OR email LIKE ?", "%#{query}%", "%#{query}%")
                           .order(created_at: :desc)
                   else
                     Regist.where(trash: true).order(created_at: :desc)
                   end

    @total_count = all_regists.count  # 検索件数（全体件数）
    @total_pages = (@total_count / PER_PAGE.to_f).ceil
    offset = (@current_page - 1) * PER_PAGE

    @regists = all_regists.offset(offset).limit(PER_PAGE)
    @related_contact_email_hashes = Contact.pluck(:email_hash).uniq

    render :trash
  end

  def unread #未読
    query = params[:query]
    @current_page = params[:page].to_i > 0 ? params[:page].to_i : 1
    offset = (@current_page - 1) * PER_PAGE

    all_regists = if query.present?
                     Regist.where(unread: false, trash: false)
                           .where("name LIKE ? OR email LIKE ?", "%#{query}%", "%#{query}%")
                           .order(created_at: :desc)
                   else
                     Regist.where(unread: false, trash: false).order(created_at: :desc)
                   end

    @total_count = all_regists.count  # 追加：未読件数

    @total_pages = (@total_count.to_f / PER_PAGE).ceil
    @regists = all_regists.offset(offset).limit(PER_PAGE)

    # 「お問合せあり」判定用にcontactsのemail_hashを取得
    @related_contact_email_hashes = Contact.pluck(:email_hash).uniq

    render :unread
  end
  
  def readed
    query = params[:query]
    @current_page = params[:page].to_i > 0 ? params[:page].to_i : 1
    offset = (@current_page - 1) * PER_PAGE

    all_regists = if query.present?
                     Regist.where(unread: true, trash: false)
                           .where("name LIKE ? OR email LIKE ?", "%#{query}%", "%#{query}%")
                           .order(created_at: :desc)
                   else
                     Regist.where(unread: true, trash: false).order(created_at: :desc)
                   end

    @total_count = all_regists.count  # 追加：既読の件数を代入

    @total_pages = (@total_count.to_f / PER_PAGE).ceil
    @regists = all_regists.offset(offset).limit(PER_PAGE)

    # 「お問合せあり」判定用にcontactsのemail_hashを取得
    @related_contact_email_hashes = Contact.pluck(:email_hash).uniq

    render :readed
  end

  def multiple
    case params[:action_type]
    when "Destroy"
      # ゴミ箱処理
      if params[:regist_ids].present?
        if request.referer&.include?("regists/trash") # ゴミ箱から来たとき
          Regist.where(id: params[:regist_ids]).destroy_all
          flash[:notice] = "選択されたお問い合わせを完全に削除しました。"
        else # 通常の一覧から来たとき
          Regist.where(id: params[:regist_ids]).update_all(trash: true)
          flash[:notice] = "選択されたお問い合わせをゴミ箱に移動しました。"
        end
      else
        flash[:alert] = "削除するお問い合わせのチェックボックスを選択してください。"
      end
      redirect_to request.referer || management_screen_regists_path
    when "Read"
      # 既読処理
      if params[:regist_ids].present?
        ids = params[:regist_ids].map(&:to_i)
        Regist.where(id: ids).update_all(unread: true)

        flash[:notice] = ids.map { |id| "ID #{id} の受信データを既読にしました。" }.join("\n").html_safe
      else
        flash[:alert] = "チェックされたデータがありません。"
      end
      redirect_back fallback_location: management_screen_regists_path
    when "Unread"
      # 未読処理
      if params[:regist_ids].present?
        ids = params[:regist_ids].map(&:to_i)
        Regist.where(id: ids).update_all(unread: false)

        flash[:notice] = ids.map { |id| "ID #{id} の受信データを未読にしました。" }.join("\n").html_safe
      else
        flash[:alert] = "チェックされたデータがありません。"
      end
      redirect_back fallback_location: management_screen_regists_path
    when "Restore"
      if params[:regist_ids].present?
        Regist.where(id: params[:regist_ids]).update_all(trash: 0)
        flash[:notice] = "選択したデータを復元しました。"
      else
        flash[:alert] = "復元するデータを選択してください。"
      end
      redirect_back fallback_location: management_screen_regists_path
    end

  end

  def destroy_multiple
    contact_ids = Array(params[:contact_ids]).reject(&:blank?)
    reply_ids   = Array(params[:reply_ids]).reject(&:blank?)
    regist_ids  = Array(params[:regist_ids]).reject(&:blank?)

    if contact_ids.empty? && reply_ids.empty? && regist_ids.empty?
      redirect_back fallback_location: management_screen_regists_path,
                    alert: "削除対象を選択してください。"
      return
    end

    if regist_ids.any?
      if request.referer&.include?("regists/trash")
        Regist.where(id: regist_ids).destroy_all
        flash[:notice] = "選択された予約希望者を完全に削除しました。"
      else
        Regist.where(id: regist_ids).update_all(trash: true)
        flash[:notice] = "選択された予約希望者をゴミ箱に移動しました。"
      end
    end

    if contact_ids.any?
      Contact.where(id: contact_ids).update_all(trash: true)
      flash[:notice] = "選択されたお問い合わせをゴミ箱に移動しました。"
    end

    if reply_ids.any?
      Reply.where(id: reply_ids).update_all(trash: true)
      flash[:notice] = "選択された返信をゴミ箱に移動しました。"
    end

    redirect_to request.referer || management_screen_regists_path
  end

  def destroy_completely  # データの完全削除
    if params[:regist_ids].present?
      Regist.where(id: params[:regist_ids]).destroy_all
      flash[:notice] = "選択されたお問い合わせを完全に削除しました。"
    else
      flash[:alert] = "削除するお問い合わせのチェックボックスを選択してください。"
    end
    redirect_to management_screen_regists_path
  end

  def mark_read_multiple
    # 既読処理
    if params[:regist_ids].present?
      ids = params[:regist_ids].map(&:to_i)
      Regist.where(id: ids).update_all(unread: true)

      flash[:notice] = ids.map { |id| "ID #{id} の受信データを既読にしました。" }.join("\n").html_safe
    else
      flash[:alert] = "チェックされたデータがありません。"
    end
    redirect_back fallback_location: management_screen_regists_path
  end

  def mark_unread_multiple
    # 未読処理
    if params[:regist_ids].present?
      ids = params[:regist_ids].map(&:to_i)
      Regist.where(id: ids).update_all(unread: false)

      flash[:notice] = ids.map { |id| "ID #{id} の受信データを未読にしました。" }.join("\n").html_safe
    else
      flash[:alert] = "チェックされたデータがありません。"
    end
    redirect_back fallback_location: management_screen_regists_path
  end

  def mark_read
    Rails.logger.error("==== def mark_read アクションに入りました")
    regist = Regist.find(params[:id])
    regist.update(unread: 1)
    head :ok
  rescue => e
    Rails.logger.error("==== MARK_READ ERROR: #{e.message}")
    Rails.logger.error e.backtrace.join("\n")
    head :unprocessable_entity
  end

  def restore_multiple_from_trash
    if params[:regist_ids].present?
      Regist.where(id: params[:regist_ids]).update_all(trash: 0)
      flash[:notice] = "選択したデータを復元しました。"
    else
      flash[:alert] = "復元するデータを選択してください。"
    end
    redirect_back fallback_location: management_screen_regists_path
  end

  def sent_reply
    @regist = Regist.find(params[:id])
    email_hash = Digest::SHA256.hexdigest(@regist.email.to_s.downcase.strip)

    @regist.reply_subject = params[:regist][:reply_subject]
    @regist.reply_body    = params[:regist][:reply_body]

    @regist.errors.add(:reply_subject, '件名を入力してください') if @regist.reply_subject.blank?
    @regist.errors.add(:reply_body, '本文を入力してください') if @regist.reply_body.blank?

    # エラー時はフォームへ戻る
    if @regist.errors.any?
      render :reply and return
    end

    # Reply レコード作成
    reply = Reply.new(
      name: @regist.name,
      subject: @regist.reply_subject,
      email_hash: email_hash,
      message: @regist.reply_body,
      unread: false,
      regist_id: @regist.id   # ← regist_id があるなら、この1行だけでOK  #これは削除 2025/12/3
    )

    if reply.save

      # Registに返信した時刻を保存
      @regist.update(email_sent_01: Time.current)

      # これが原因なので完全削除
      # reply.update(id: @regist.id)

      # メール送信
      RegistMailer.reply_to_user(@regist, @regist.reply_subject, @regist.reply_body).deliver_now

      redirect_to thread_management_screen_regists_path(query: @regist.email, page: 1), notice: '返信を送信しました'
    else
      Rails.logger.error "Reply 保存失敗: #{reply.errors.full_messages.join(', ')}"
      flash.now[:alert] = '返信の保存に失敗しました。'
      render :reply
    end
  end

  def thread  # お問合せ履歴
    @back_page = params[:back_page] || 1
    email = params[:query].to_s.strip.downcase
    email_hash = Digest::SHA256.hexdigest(email)

    # お問合せと返信を両方取得
    contacts = Contact.where(email_hash: email_hash)
                      .where(trash: [false, nil])

    replies = Reply.where(email_hash: email_hash)
                   .where(trash: [false, nil])

    @messages = []

    contacts.each do |contact|
      @messages << {
        type: :contact,
        id: contact.id,
        name: contact.name,
        subject: contact.subject,
        message: contact.message,
        datetime: contact.created_at,
        unread: contact.unread
      }
    end

    @contact_total_count = @messages.count # 受信

    replies.each do |reply|
      @messages << {
        type: :reply,
        id: reply.id,
        name: reply.name,
        subject: reply.subject,
        message: reply.message,
        datetime: reply.created_at,
        unread: reply.unread,
        regist_id: reply.regist_id,
        contact_id: reply.contact_id
      }
    end

    @messages_count = @messages.count # 返信
    @reply_total_count = @messages_count - @contact_total_count

    # 日時で並び替え（昇順・または必要に応じて降順）
    #@messages.sort_by! { |m| m[:datetime] }
    @messages.sort_by! { |m| m[:datetime] || Time.at(0) }.reverse!

    @total_count = @messages.count  # 検索件数（全体件数）

    @email = email  # ビューで表示用

    @current_page = params[:page].to_i > 0 ? params[:page].to_i : 1
    offset = (@current_page - 1) * PER_PAGE
    @total_pages = (@total_count.to_f / PER_PAGE).ceil
    @messages = @messages.slice(offset, PER_PAGE) || []

    render :thread
  end

  # 要る？
  def sort_mail
    email = params[:query]
    email_hash = Digest::SHA256.hexdigest(email.downcase.strip)

    regists = Regist.where(email: email)
    replies = Reply.where(email_hash: email_hash)

    # 統一された形式にしてマージ
    messages = []

    regists.each do |regist|
      messages << {
        type: :received,
        name: regist.name,
        email: regist.email,
        message: "（予約登録済み）",
        datetime: regist.created_at
      }
    end

    replies.each do |reply|
      messages << {
        type: :sent,
        name: reply.name,
        email: nil,
        subject: reply.subject,
        message: reply.message,
        datetime: reply.sent_datetime
      }
    end

    # 日時順でソート
    @sorted_messages = messages.sort_by { |msg| msg[:datetime] }

    @email = email
  end

  # 手動で、ダウンロード先の、tokenつきのURLをメールでお送りするためのメソッド
  def reply
    @regist = Regist.find(params[:id])

    # 初回表示時のみ初期値を設定（バリデーション後の再描画では上書きしない）
    unless params[:regist]
      @regist.reply_subject = "Present 電子書籍『死闘の使命』完成 Download URL"

      quoted_message = "#{@regist.name}"
      from_ariaguma = <<~TEXT
        ARIAGUMA GROUP のARIAGUMAです。
        著書『死闘の使命』が完成いたしましたことをお知らせいたします。
        
        以前は、ARIAGUMA GROUPにて、Present電子書籍『死闘の使命』
        のDOWNLOAD を登録予約を受けつけされまので、
        本メールをお送りさせて頂きました。
        
        下記のURLからダウンロードなさってくだいませ。
        <a href="https://ariaguma.jp/download/#{@regist.token}">https://ariaguma.jp/download/#{@regist.token}</a>
      TEXT

      @regist.reply_body = "#{quoted_message} さま\n\n#{from_ariaguma}"
    end

  end

  def restore_from_trash # ゴミ箱から復元
    @regist = Regist.find(params[:id])
    if @regist.update(trash: 0)
      redirect_to management_screen_regists_path, notice: "元に戻しました。"
    else
      redirect_to trash_management_screen_regists_path, alert: "元に戻せませんでした。"
    end
  end

  def send_first_book  # regists 予約者へ管理者が返信 CODE CHECK 2026/6/26

    @regist = Regist.find(params[:id])

    if @regist.email_sent_01.present?
      redirect_to management_screen_regist_path(@regist), alert: "すでに送信済みです"
      return
    end

    @regist.update(email_sent_01: Time.current)
    @regist.update(subscribed: 1)

    # TEMPLATE FILES
    # app/views/regist_mailer/notify_to_sender.text.erb || notify_to_sender.text.erb
    begin
      RegistMailer.notify_to_sender(@regist).deliver_now
    rescue => e
      Rails.logger.error("メール送信エラー: #{e.message}")
    end

    Reply.create!(
      name: @regist.name,
      subject: "Present『死闘の使命』DOWNLOAD ARIAGUMA",
      email_hash: @regist.email_hash,
      message: "電子書籍のダウンロードURLを記載したメールを送信しました。",
      regist_id: @regist.id,
      unread: false,
      trash: false
    )

    redirect_to management_screen_regist_path(@regist), notice: "ダウンロードURLを記載したメールを送信しました"
  end

  # app/controllers/management_screen/regist_mailer.rb
  # /home/ubuntu/projects/ariaguma/app/views/regist_mailer/second_download_email.text.erb
  # || second_download_email.text.erb
  def send_second_email #CODE CHECK OK 2026/6/26
    @regist = Regist.find(params[:id])

    RegistMailer.second_download_email(@regist).deliver_now

    Reply.create!(
      name: @regist.name,
      subject: 'ARIAGUMA 2冊目の電子書籍のDOWNLOAD のご通知です',
      email_hash: @regist.email_hash,
      message: "電子書籍のダウンロードURLを記載したメールを送信しました。",
      regist_id: @regist.id,
      unread: false,
      trash: false
    )

    @regist.update(email_sent_02: Time.current)

    redirect_to management_screen_regist_path(@regist), notice: '2冊目のメールを送信しました。'
  end

  private
  
  def set_counts
    @all_regists_count = Regist.where(trash: 0).count       # 全件カウント
    @trash_count = Regist.where(trash: 1).count             # ゴミ箱カウント
    @unread_count = Regist.where(unread: 0, trash: 0).count # 未読カウント
    @read_count = Regist.where(unread: 1, trash: 0).count   # 既読カウント
  end

end


