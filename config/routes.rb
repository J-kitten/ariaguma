# config/routes.rb
Rails.application.routes.draw do
  get 'inquiries/new'
  get 'inquiries/create'
  get 'ebooks/download'
  get "home/index"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"

  root 'home#index'
  post 'home/create', to: 'home#create'
  
  get "contact", to: "home#contact"         # お問合せページ
  get "book_present", to: "home#book_present" # 無料本のダウンロードぺージ
  get "donation", to: "home#donation"       # ご寄付ページ
  get "about", to: "home#about"             # 団体概要ページ
  get "privacy_policy", to: "home#privacy_policy" # プライバシーポリシー
  get 'legal', to: 'pages#legal'           # 特定商取引法
  get 'set_language/:lang', to: 'application#set_language', as: :set_language

  post '/google_login', to: 'google_auth#login'
  get '/me', to: 'users#me'
  #post "/logout", to: "google_auth#logout"
  #post "/logout", to: "logout#destroy"
  post "/logout", to: "sessions#destroy"

  post "/auth/login", to: "auth#login"
  post "/auth/logout", to: "auth#logout"
  get  "/auth/me", to: "auth#me"

  resources :regists, only: [:index ,:create] do
    collection do
      get :complete
    end
  end

  post 'send_form', to: 'home#send_form'

  get 'download/:token', to: 'downloads#show', as: 'download' # ダウンロードページ表示
  post 'download/:token', to: 'downloads#download_files', as: 'download_files' # ファイルの選択・ダウンロード処理

  #post "downloads/:token/:filename", to: "downloads#file", as: :download_ebook
  post 'downloads/:token/:filename', to: 'downloads#file', as: 'download_file'

  resources :regists, only: [:create]

  resources :contacts, only: [:new, :create, :index, :show, :destroy]

  resources :inquiries, only: [:new, :create]

  patch 'download/:token/subscribe', to: 'downloads#subscribe', as: :subscribe_download
  patch 'download/:token/unsubscribe', to: 'downloads#unsubscribe', as: :unsubscribe_download

  patch "/api/profile", to: "api/profile#update"  # プロフィール再設定

  namespace :management_screen do
    get "regist_book",
        to: "download_files#new",
        as: :regist_book

    resources :download_files
  end

  # 各一覧ページへのルート（仮のコントローラー名とアクション）
  get 'reservations', to: 'reservations#index' #予約 
  get 'inquiries', to: 'inquiries#index' #お問合せ インクリーズ

  namespace :api do
    resource :session,
             controller: :sessions,
             only: [:create, :destroy] do
      collection do
        get :me
      end
    end
  end

  namespace :management_screen do
    # contacts
    resources :contacts, only: [:index, :show] do
      member do
        get :reply        # /management_screen/contacts/:id/reply
        post :sent_reply  # replyのPOSTアクション名
        patch :mark_read
        patch :restore
        get :trash_show
        get :thread_detail
      end
      collection do
        get :unread
        get :readed
        get :trash     # /management_screen/contacts/trash
        get :search    # /management_screen/contacts/search
        get :trash_search
        post :multiple
        post :mark_read_multiple     # 複数を既読にする
        post :mark_unread_multiple   # 複数を未読にする
        get :reply_detail   # => reply_detail_management_screen_contacts_path
        get :not_replying   # => not_replying_management_screen_contacts_path
        post :restore_multiple_from_trash
      end
    end

    resources :regists, only: [:index, :show] do
      member do
        patch :toggle_unread # 不要かも
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

      resources :regists_replies, only: [:new, :create, :index]
    end

    # replies
    resources :replies, only: [:show, :index]

    # 管理画面配下のリソース
    get 'regists', to: 'regists#index'  # 予約希望者一覧
    get 'contacts', to: 'contacts#index'  # お問合せ一覧
    match 'logout', to: 'sessions#destroy', via: [:get, :delete], as: :logout

  end

  # https://ariaguma.jp/download/second_download/token
  get 'download/second_download/:token', to: 'downloads#second', as: 'second_download'

  scope :management_screen do
    #get  'signin', to: 'users#new',    as: :management_screen_signin_path
    get  'signup', to: 'users#new',    as: :management_screen_signup_path
    post 'create', to: 'users#create', as: :management_screen_create_path
  end

  get '/destroy', to: 'sessions#destroy_view', as: :logout_complete

  # 管理画面トップページ
  get 'management_screen', to: 'management_screen#index', as: :management_screen

  get 'management_screen/login',  to: 'sessions#new', as: :login
  post 'management_screen/login',  to: 'sessions#create'

  # Firebase
  get  "/mypage", to: "mypage#show"
  post "/firebase_login", to: "firebase_sessions#create"
  delete "/logout", to: "firebase_sessions#destroy"

  get  "/mypage/contacts/:id", to: "mypage#contact_show", as: :mypage_contact
  post "/mypage/contacts/:id/reply", to: "mypage#contact_reply", as: :mypage_contact_reply

  get  "mypage/replies/:id",       to: "mypage#reply_show",  as: :mypage_reply
  post "mypage/replies/:id/reply", to: "mypage#reply_reply", as: :mypage_reply_reply

  delete "/firebase_logout", to: "firebase_sessions#destroy"

  namespace :management_screen do
    root "dashboard#index"

    resources :download_files
    resources :contacts
    resources :regists
  end

  class ErrorsController < ApplicationController
    def not_found
      redirect_to root_path
    end
  end

  match "*path", to: "errors#not_found", via: :all

end
