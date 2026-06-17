# app/controllers/contacts_controller.rb
class ContactsController < ApplicationController

  def create
    @contact = Contact.new(contact_params)
    if @contact.save
      flash[:admin_notice] = "お問い合わせが送信されました。"
      redirect_to :contact
    else
      flash.now[:admin_alert] = "入力内容に不備があります。"
      render "home/contact"  # または適切なビュー
    end
  end

  def index
    if params[:query].present?
      # メールアドレスまたはハッシュで絞り込み
      #@contacts = Contact.where(email: params[:query])
      @contacts = Contact.where(email_hash: params[:query])
    else
      @contacts = Contact.all
    end
  end

  def destroy_multiple
    if params[:contact_ids].present? || params[:reply_ids].present?
      if request.referer&.include?("regists/trash") # ゴミ箱から来たとき
        Contact.where(id: params[:contact_ids]).destroy_all if params[:contact_ids].present?
        Reply.where(id: params[:reply_ids]).destroy_all if params[:reply_ids].present?
        flash[:admin_notice] = "選択されたお問い合わせを完全に削除しました。"
      else # 通常の一覧から来たとき
        Contact.where(id: params[:contact_ids]).update_all(trash: true) if params[:contact_ids].present?
        Reply.where(id: params[:reply_ids]).update_all(trash: true) if params[:reply_ids].present?
        flash[:admin_notice] = "選択されたお問い合わせをゴミ箱に移動しました。"
      end
    else
      flash[:admin_alert] = "削除するお問い合わせを選択してください。"
    end

    redirect_to request.referer || management_screen_regists_path
  end

  def mark_read_multiple
    if params[:contact_ids].present?
      ids = params[:contact_ids].map(&:to_i)
      Contact.where(id: ids).update_all(unread: true)

      flash[:admin_notice] = ids.map { |id| "ID #{id} の受信データを既読にしました。" }.join("<br>").html_safe
    else
      flash[:admin_alert] = "チェックされたデータがありません。"
    end
    redirect_back fallback_location: management_screen_regists_path
  end

  def mark_unread_multiple
    if params[:contact_ids].present?
      ids = params[:contact_ids].map(&:to_i)
      Contact.where(id: ids).update_all(unread: false)

      flash[:admin_notice] = ids.map { |id| "ID #{id} の受信データを未読にしました。" }.join("<br>").html_safe
    else
      flash[:admin_alert] = "チェックされたデータがありません。"
    end
    redirect_back fallback_location: management_screen_regists_path
  end

  private

  def contact_params
    params.require(:contact).permit(:name, :email, :email_confirmation, :subject, :message)
  end

end
