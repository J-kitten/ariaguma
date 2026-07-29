class ManagementScreen::DashboardController < ApplicationController

  def index
    # 予約人数
    @regists_count = Regist.where(trash: false).count

    # お問い合わせ未返信
    @unanswered_contacts_count = Contact.where(
                                         trash: false,
                                         reply_time: nil
                                        ).count

    # 公開中電子書籍
    @published_books_count = DownloadFile.where(published: true).count

    # 制作中電子書籍
    @unpublished_books_count = DownloadFile.where(published: false).count

    @today_downloads_count = 0
    @month_downloads_count = 0

    # 今日のダウンロード
    #@today_downloads_count = DownloadLog.where(
                              # downloaded_at: Time.current.all_day
                              #).count

    # 今月のダウンロード
    #@month_downloads_count = DownloadLog.where(
                                          #downloaded_at: Time.current.all_month
                                         #).count

    # 最近の予約
    @recent_regists = Regist.where(trash: false)
                            .order(created_at: :desc)
                            .limit(5)

    # 最近のお問い合わせ
    @recent_contacts = Contact.where(trash: false)
                              .order(created_at: :desc)
                              .limit(5)
  end
end
