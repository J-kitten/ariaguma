# config/routes.rb

Rails.application.routes.draw do
  # ----------------------------------------
  # トップページ・一般ページ
  # ----------------------------------------

  root "home#index"

  get "home/index", to: "home#index"
  post "home/create", to: "home#create"

  get "contact", to: "home#contact"
  get "book_present", to: "home#book_present"
  get "donation", to: "home#donation"
  get "about", to: "home#about"
  get "privacy_policy", to: "home#privacy_policy"
  get "legal", to: "pages#legal"
  get "set_language/:lang", to: "application#set_language", as: :set_language

  post "send_form", to: "home#send_form"

  # ----------------------------------------
  # ヘルスチェック
  # ----------------------------------------

  get "up", to: "rails/health#show", as: :rails_health_check

  # ----------------------------------------
  # Google認証・通常認証
  # ----------------------------------------

  post "google_login", to: "google_auth#login"
  get "me", to: "users#me"

  post "auth/login", to: "auth#login"
  post "auth/logout", to: "auth#logout"
  get "auth/me", to: "auth#me"

  namespace :api do
    resource :session, controller: :sessions, only: %i[create destroy] do
      collection do
        get :me
      end
    end

    patch "profile", to: "profile#update"
  end

  # ----------------------------------------
  # 予約登録
  # ----------------------------------------

  resources :regists, only: %i[index create] do
    collection do
      get :complete
    end
  end

  # ----------------------------------------
  # お問い合わせ
  # ----------------------------------------

  resources :contacts, only: %i[new create index show destroy]
  resources :inquiries, only: %i[new create]

  get "reservations", to: "reservations#index"
  get "inquiries", to: "inquiries#index"

  # ----------------------------------------
  # 電子書籍ダウンロード
  # ----------------------------------------

  get "download/:token", to: "downloads#show", as: :download
  post "download/:token/file", to: "downloads#file", as: :download_file
  patch "download/:token/subscribe", to: "downloads#subscribe", as: :subscribe_download
  patch "download/:token/unsubscribe", to: "downloads#unsubscribe", as: :unsubscribe_download

  get "download/second_download/:token", to: "downloads#second", as: :second_download
  post "download/second/:token/file", to: "downloads#second_file", as: :second_download_file

  # ----------------------------------------
  # 管理画面ログイン
  # ----------------------------------------

  get "management_screen/login", to: "sessions#new", as: :login
  post "management_screen/login", to: "sessions#create"

  get "management_screen/signup", to: "users#new", as: :management_screen_signup
  post "management_screen/create", to: "users#create", as: :management_screen_create

  get "destroy", to: "sessions#destroy_view", as: :logout_complete

  # ----------------------------------------
  # 管理画面
  # ----------------------------------------

  namespace :management_screen do
    root "dashboard#index"

    match "logout", to: "sessions#destroy", via: %i[get delete], as: :logout

    get "regist_book", to: "download_files#new", as: :regist_book

    resources :download_files

    resources :download_logs, only: %i[index show]

    resources :contacts, only: %i[index show] do
      member do
        get :reply
        post :sent_reply
        patch :mark_read
        patch :restore
        get :trash_show
        get :thread_detail
      end

      collection do
        get :unread
        get :readed
        get :trash
        get :search
        get :trash_search
        get :reply_detail
        get :not_replying
        post :multiple
        post :mark_read_multiple
        post :mark_unread_multiple
        post :restore_multiple_from_trash
      end
    end

    resources :regists, only: %i[index show] do
      member do
        patch :toggle_unread
        patch :mark_read
        get :reply
        post :restore_from_trash
        post :sent_reply
        post :send_first_book
        post :send_second_email
      end

      collection do
        get :search
        get :trash
        get :unread
        get :readed
        get :trash_search
        get :sorted_messages
        get :thread
        post :send_email_01
        post :send_email_02
        post :move_to_trash
        post :restore_multiple_from_trash
        post :multiple
        post :destroy_multiple
        patch :mark_read_multiple
        patch :mark_unread_multiple
        delete :destroy_completely
      end

      resources :regists_replies, only: %i[new create index]
    end

    resources :replies, only: %i[index show]
  end

  # ----------------------------------------
  # Firebase・マイページ
  # ----------------------------------------

  get "mypage", to: "mypage#show"

  post "firebase_login", to: "firebase_sessions#create"
  delete "firebase_logout", to: "firebase_sessions#destroy"

  get "mypage/contacts/:id", to: "mypage#contact_show", as: :mypage_contact
  post "mypage/contacts/:id/reply", to: "mypage#contact_reply", as: :mypage_contact_reply

  get "mypage/replies/:id", to: "mypage#reply_show", as: :mypage_reply
  post "mypage/replies/:id/reply", to: "mypage#reply_reply", as: :mypage_reply_reply

  # ----------------------------------------
  # 存在しないURL
  # ----------------------------------------

  match "*path", to: "errors#not_found", via: :all
end
