# app/controllers/management_screen/contacts_controller.rb
class ManagementScreen::ContactsController < ManagementScreen::BaseController
  before_action :set_counts, only: [:index, :trash, :unread, :readed, :search, :trash_search ]

  layout 'management'

  PER_PAGE = 10

  before_action :set_contact, only: [:show, :destroy, :reply]
  before_action :set_no_cache, only: [:index]

  def create
    @contact = Contact.new(contact_params)
    if @contact.save
      flash[:notice] = "お問い合わせ内容を送信しました。"
      redirect_to contact_path
    else
      flash.now[:alert] = "送信内容に不備があります。"
      render "home/contact"
    end
  end

  def index
    @query = params[:query]
    per_page = 10
    page = (params[:page] || 1).to_i
    offset = (page - 1) * per_page

    if params[:query].present?
      query = params[:query].strip.downcase
      email_hash = Digest::SHA256.hexdigest(query)
      @contacts = Contact.where(trash: false, email_hash: email_hash)
                         .order(created_at: :desc)
    else
      @contacts = Contact.where(trash: false)
                         .order(created_at: :desc)
    end

    @total_pages = (@contacts.count.to_f / per_page).ceil
    @current_page = page
    @contacts = @contacts.offset(offset).limit(per_page)

  end

  def thread_detail
    @contact = Contact.find(params[:id])
    @back_query = params[:query]
    render :thread_detail
  end

  def show
    @contact = Contact.find(params[:id])
    @query = params[:query]
    @page = params[:page]

    if !params[:id] && params[:mark_read] == "read_on"
      Rails.logger.info "★★★Contact ID #{params[:mark_read]} marked as read★★★" 
      mark_as_read(params[:id], params[:mark_read]) if params[:mark_read] == "read_on"
    end
  end

  def mark_as_read(contact_id, check_read)
    @contact = Contact.find(contact_id)
    if @contact.unread == false && check_read == "read_on"
      Rails.logger.info "★★★Contact ID #{@contact.id} marked as read★★★"
      # SQL直実行のままで安全な書き方（quote済）
      id = ActiveRecord::Base.connection.quote(contact_id.to_i)
      ActiveRecord::Base.connection.execute("UPDATE contacts SET unread = true WHERE id = #{id}")
      # もしくは ActiveRecord で書き換えるなら：
      # @contact.update_column(:unread, true)
      Rails.logger.info("conatcts unread の update 完了")
    end
  end

  def mark_read
    contact = Contact.find(params[:id])
    contact.unread = true
    #contact.update(unread: 1)
    if contact.save(validate: false)
      head :ok
    else
      Rails.logger.error(
        "[Contact Mark Read Validation Error] " \
        "contact_id=#{contact.id}, " \
        "errors=#{contact.errors.full_messages.join(', ')}"
      )

      render json: {
        success: false,
        error_code: "VALIDATION_ERROR",
        message: "既読状態を更新できませんでした。",
        details: {
          errors:
            contact.errors.full_messages
        }
      }, status: :unprocessable_entity
    end
  end

  def destroy
    @contact.update(trash: true)
    redirect_to management_screen_contacts_path, notice: '削除しました。'
  end

  def trash  # ゴミ箱
    @current_page = params[:page].to_i > 0 ? params[:page].to_i : 1
    offset = (@current_page - 1) * PER_PAGE

    # ゴミ箱に入っているデータのみ取得
    all_contacts = Contact.where(trash: true).order(created_at: :desc)

    @total_pages = (all_contacts.count.to_f / PER_PAGE).ceil
    @contacts = all_contacts.offset(offset).limit(PER_PAGE)
  end

  def trash_search
    query = params[:query]
    @current_page = params[:page].to_i > 0 ? params[:page].to_i : 1
    offset = (@current_page - 1) * PER_PAGE

    if query.present? && query.length > 80
      flash[:alert] = "検索ワードは80文字以内で入力してください。"
      redirect_to management_screen_contacts_path(query: query, page: @current_page) and return
    end

    # 検索条件：ゴミ箱内、複数カラムに対してLIKE検索
    all_contacts = if query.present?
                    Contact.where("name LIKE :q OR email LIKE :q OR subject LIKE :q OR message LIKE :q", q: "%#{query}%")
                          .where(trash: true)
                          .order(created_at: :desc)
                   else
                     Contact.where(trash: true).order(created_at: :desc)
                   end

    @contacts = all_contacts.offset(offset).limit(PER_PAGE)

    @total_count = all_contacts.count  # 追加：検索件数を変数に格納

    @total_pages = (@total_count.to_f / PER_PAGE).ceil

    render :trash
  end

  def search
    query = params[:query]
    @current_page = params[:page].to_i > 0 ? params[:page].to_i : 1
    offset = (@current_page - 1) * PER_PAGE

    if query.present? && query.length > 80
      flash[:alert] = "検索ワードは80文字以内で入力してください。"
      redirect_to management_screen_contacts_path(query: query, page: @current_page) and return
    end

    # ベース：ゴミ箱以外
    all_contacts = Contact.where(trash: false)

    if params[:unread] == "0" # 未読
      all_contacts = all_contacts.where(unread: 0)
    end
    if params[:unread] == "1" # 既読
      all_contacts = all_contacts.where(unread: 1)
    end

    # キーワード検索条件
    all_contacts = if query.present?
                     Contact.where("name LIKE :q OR email LIKE :q OR subject LIKE :q OR message LIKE :q", q: "%#{query}%")
                        .where(trash: 0)
                        .order(created_at: :desc)
                   else
                     Contact.where(trash: 0).order(created_at: :desc)
                   end

    @contacts = all_contacts.offset(offset).limit(PER_PAGE)

    @total_count = all_contacts.count
    @total_pages = (@total_count.to_f / PER_PAGE).ceil

    render :index
  end

  def multiple
    case params[:action_type]
    when "Destroy"
      # ゴミ箱処理
      if params[:contact_ids].present?
        if request.referer&.include?("contacts/trash") # ゴミ箱から来たとき
          Contact.where(id: params[:contact_ids]).destroy_all
          flash[:notice] = "選択されたお問い合わせを完全に削除しました。"
        else # 通常の一覧から来たとき
          Contact.where(id: params[:contact_ids]).update_all(trash: true)
          flash[:notice] = "選択されたお問い合わせをゴミ箱に移動しました。"
        end
      else
        flash[:alert] = "削除するお問い合わせのチェックボックスを選択してください。"
      end
      redirect_to request.referer || management_screen_contacts_path

    when "Read"
      # 既読処理
      if params[:contact_ids].present?
        ids = params[:contact_ids].map(&:to_i)
        Contact.where(id: ids).update_all(unread: true)

        flash[:notice] = ids.map { |id| "ID #{id} の受信データを既読にしました。" }.join("\n").html_safe
      else
        flash[:alert] = "チェックされたデータがありません。"
      end
      redirect_back fallback_location: management_screen_contacts_path
    when "Unread"
      # 未読処理
      if params[:contact_ids].present?
        ids = params[:contact_ids].map(&:to_i)
        Contact.where(id: ids).update_all(unread: false)

        flash[:notice] = ids.map { |id| "ID #{id} の受信データを未読にしました。" }.join("\n").html_safe
      else
        flash[:alert] = "チェックされたデータがありません。"
      end
      redirect_back fallback_location: management_screen_contacts_path
    when "Restore"
      if params[:contact_ids].present?
        Contact.where(id: params[:contact_ids]).update_all(trash: 0)
        flash[:notice] = "選択したデータを復元しました。"
      else
        flash[:alert] = "復元するデータを選択してください。"
      end
      redirect_back fallback_location: management_screen_contacts_path
    end
  end

  def unread # 未読
    query = params[:query] # 今後の拡張用
    @current_page = params[:page].to_i > 0 ? params[:page].to_i : 1
    offset = (@current_page - 1) * PER_PAGE

    if query.present? && query.length > 80
      flash[:alert] = "検索ワードは80文字以内で入力してください。"
      redirect_to management_screen_contacts_path(query: query, page: @current_page) and return
    end

    all_contacts = if query.present?
                     Contact.where("name LIKE :q OR email LIKE :q OR subject LIKE :q OR message LIKE :q", q: "%#{query}%")
                        .where(unread: false, trash: false)
                        .order(created_at: :desc)
                   else
                     Contact.where(unread: false, trash: false).order(created_at: :desc)
                   end

    @total_count = all_contacts.count  # ✅ 追加：未読件数

    @total_pages = (@total_count.to_f / PER_PAGE).ceil
    @contacts = all_contacts.offset(offset).limit(PER_PAGE)

    render :unread
  end

  def readed # 既読
    query = params[:query] # 今後の拡張用
    @current_page = params[:page].to_i > 0 ? params[:page].to_i : 1
    offset = (@current_page - 1) * PER_PAGE

    if query.present? && query.length > 80
      flash[:alert] = "検索ワードは80文字以内で入力してください。"
      redirect_to management_screen_contacts_path(query: query, page: @current_page) and return
    end

    all_contacts = if query.present?
                     Contact.where("name LIKE :q OR email LIKE :q OR subject LIKE :q OR message LIKE :q", q: "%#{query}%")
                        .where(unread: true, trash: false)
                        .order(created_at: :desc)
                   else
                     Contact.where(unread: true, trash: false).order(created_at: :desc)
                   end

    @total_count = all_contacts.count  # 追加：既読の件数を代入

    @total_pages = (@total_count.to_f / PER_PAGE).ceil
    @contacts = all_contacts.offset(offset).limit(PER_PAGE)

    render :readed
  end

  def trash_show
    @contact = Contact.find(params[:id])
    unless @contact.trash
      redirect_to management_screen_contacts_path, alert: "このデータはゴミ箱にありません。"
    end
  end

  def restore # ゴミ箱から復元
    contact = Contact.find(params[:id])
    if contact.update(trash: false)
      redirect_to management_screen_contacts_path, notice: "元に戻しました。"
    else
      redirect_to trash_management_screen_contacts_path, alert: "元に戻せませんでした。"
    end
  end

  def mark_read_multiple
    if params[:contact_ids].present?
      ids = params[:contact_ids].map(&:to_i)
      Contact.where(id: ids).update_all(unread: true)

      flash[:notice] = ids.map { |id| "ID #{id} の受信データを既読にしました。" }.join("\n").html_safe
    else
      flash[:alert] = "チェックされたデータがありません。"
    end
    redirect_back fallback_location: management_screen_contacts_path
  end

  def mark_unread_multiple
    if params[:contact_ids].present?
      ids = params[:contact_ids].map(&:to_i)
      Contact.where(id: ids).update_all(unread: false)

      flash[:notice] = ids.map { |id| "ID #{id} の受信データを未読にしました。" }.join("\n").html_safe
    else
      flash[:alert] = "チェックされたデータがありません。"
    end
    redirect_back fallback_location: management_screen_contacts_path
  end

  def restore_multiple_from_trash
    if params[:contact_ids].present?
      Contact.where(id: params[:contact_ids]).update_all(trash: 0)
      flash[:notice] = "選択したデータを復元しました。"
    else
      flash[:alert] = "復元するデータを選択してください。"
    end
    redirect_back fallback_location: trash_management_screen_contacts_path
  end

  def sent_reply

    @contact = Contact.find(params[:id])
    email_hash = Digest::SHA256.hexdigest(@contact.email.to_s.downcase.strip)

    @contact.reply_subject = params[:contact][:reply_subject]
    @contact.reply_body    = params[:contact][:reply_body]

    @contact.errors.add(:reply_subject, '件名を入力してください') if @contact.reply_subject.blank?
    @contact.errors.add(:reply_body, '本文を入力してください') if @contact.reply_body.blank?

    # エラーがあれば返信フォームを再表示
    if @contact.errors.any?
      render :reply and return
    end

    # 返信レコードの作成
    reply = Reply.new(
      name: @contact.name,
      subject: @contact.reply_subject,
      email_hash: email_hash,
      message: @contact.reply_body,
      unread: false,
      contact_id: @contact.id
    )

    if reply.save

      # Contactに返信時間を登録
      @contact.update(reply_time: Time.current)

      # もし Reply に contact_id を登録したいなら（オプション）
      #reply.update(contact_id: @contact.id) # 削除 2025/12/3 23:38

      # メール送信
      ContactMailer.reply_to_user(@contact, @contact.reply_subject, @contact.reply_body).deliver_now

      redirect_to thread_management_screen_regists_path(query: @contact.email, page: 1), notice: '返信を送信しました'
    else
      Rails.logger.error "Reply 保存失敗: #{reply.errors.full_messages.join(', ')}"
      flash.now[:alert] = '返信の保存に失敗しました。'
      render :reply
    end
  end

  def reply_to_user(contact, reply_subject, reply_body)
    @contact = contact
    @subject = reply_subject
    @body = reply_body
    
    mail(to: @contact.email, subject: @subject)
  end

  # 手動で、個別のお問合せにメールで対応するためのメソッド
  def reply
    @contact = Contact.find(params[:id])

    # 初回表示時のみ初期値を設定（バリデーション後の再描画では上書きしない）
    unless params[:contact]
      @contact.reply_subject = "Re: #{@contact.subject}"

      quoted_message = @contact.message.lines.map { |line| "#{line}" }.join
      from_ariaguma = <<~TEXT
        この度は、ARIAGUMA のPresent『死闘の使命』電子書籍に
        登録予約されましたので、電子書籍の完成後、
        DOWNLOAD URLを記載したご案内をお送りいたします。

        現在、完成時期は未定となっております。
        今しばらくお待ちくださいますようお願い申し上げます。
      TEXT

      @contact.reply_body = "#{quoted_message}\n\n"
    end
  end

  def thread  # お問合せ履歴
    email = params[:query].to_s.strip.downcase
    email_hash = Digest::SHA256.hexdigest(email)

    # お問合せと返信を両方取得
    contacts = Contact.where(email_hash: email_hash).where(trash: [false, nil])
    replies  = Reply.where(email_hash: email_hash)

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

    replies.each do |reply|
      @messages << {
        type: :reply,
        id: reply.id,
        name: reply.name,
        subject: reply.subject,
        message: reply.message,
        datetime: reply.created_at,
        unread: reply.unread
      }
    end

    # 日時で並び替え（昇順・または必要に応じて降順）
    @messages.sort_by! { |m| m[:datetime] }

    @total_count = @messages.count  # 検索件数（全体件数）

    @email = email  # ビューで表示用
    
    render :thread
  end

  def reply_detail # お問合せ > 返信済ボタン > データ表示
    email = params[:query]
    contact_id = params[:id]
    #@contacts = Contact.where(email: query, trash: false).where.not(reply_time: nil)
    email_hash = Digest::SHA256.hexdigest(email.to_s.downcase.strip)

    @contact = Contact.find(params[:id]) # idに紐づいた返信済・返信済データを取得

    @replies = Reply.where(email_hash: email_hash)
                    .where(contact_id: params[:id])
                    .order(created_at: :desc)

    # 返信済データ
    if @contact.reply_time.present? && @contact.reply_time > @contact.created_at
Rails.logger.info("@replied_contacts: #{@replied_contacts.inspect}")
      @replied_contacts = Contact.where(email_hash: email_hash)
                                 .where("reply_time IS NOT NULL AND reply_time > created_at")
                                 .where(id: @contact.id)
    end

    # 未返信データ
    unless @contact.reply_time.present?
      @unreplied_contacts = Reply.where(email_hash: email_hash)
                                 .where(contact_id: @contact.id)
                                 .where(reply_time: nil)
    end

  end

  def not_replying  # お問合せ > 未返信ボタン > お問合せ内容と、返信ページ表示
    query = params[:query]
    @contacts = Contact.find_by(id: params[:id])
    #@contacts = Contact.where(id: id, email: query, trash: false, reply_time: nil)
  end

  private

  def contact_params
    params.require(:contact).permit(:name, :email, :email_confirmation, :subject, :message)
  end

  def set_contact
    @contact = Contact.find(params[:id])
    response.headers["Cache-Control"] = "no-store, no-cache, must-revalidate, max-age=0"
    response.headers["Pragma"] = "no-cache"
  end

  def set_no_cache
    response.headers["Cache-Control"] = "no-store"
  end
  
  def set_counts
    @all_contacts_count = Contact.where(trash: false).count
    @trash_count = Contact.where(trash: true).count
    @unread_count = Contact.where(unread: false, trash: false).count
    @read_count = Contact.where(unread: true, trash: false).count
  end

end #class

