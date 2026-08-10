module ManagementScreen
  class ManagementScreen::RepliesController < ApplicationController

    layout 'management'

    def show
      @reply = Reply.find_by(email_hash: Digest::SHA256.hexdigest(Contact.find(params[:id]).email))
    end

    #def index
      # email_hash ごとに一番新しいお問合せだけ取得
    #  latest_contacts = Contact.select('DISTINCT ON (email_hash) *')
    #                           .order('email_hash, created_at DESC')

    #  @contacts = latest_contacts
    #end

    def index
      subquery = Contact.select('email_hash, MAX(created_at) AS max_created_at')
                        .group(:email_hash)

      @contacts = Contact.joins("INNER JOIN (#{subquery.to_sql}) AS latest 
                                 ON contacts.email_hash = latest.email_hash 
                                 AND contacts.created_at = latest.max_created_at")
                         .order(created_at: :desc)
    end

    #def index
    #  if params[:email_hash].present?
    #    @replies = Reply.where(email_hash: params[:email_hash]).order(created_at: :desc)
    #  else
    #    @replies = Reply.all.order(created_at: :desc)
    #  end
    #end

  end

end