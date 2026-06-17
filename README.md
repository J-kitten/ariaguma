ARIAGUMA GROUP
GitHubなど　https://ariaguma.org/career　ID: kyoko.sato.jenipher@gmail.com Password: jenipher122839

◆概要◆
1. ユーザーがGoogleログインボタン押下　
2. Ruby on Rails を用いた電子書籍ダウンロードサイトです。　
3. ユーザー登録後、電子書籍のダウンロード URL を取得できます。　
4. また、React + Firebase Authentication を利用した Google 
   ログイン機能を実装し、既存 Rails システムとの認証連携を行っています。

■工程
1. Googleログイン機能　要件定義～設計～実装～検証～保守運用 
2. ログイン機能以外、要件整理～詳細設計～実装～検証～保守運用

■ユーザー画面
1. https://ariaguma.jp/
■管理画面
2. https://ariaguma.jp/management_screen/login
   ID：notreply@ariaguma.jp | Password：aliimoojenipher/

◆使用技術
■バックエンド
1. Ruby ruby 3.2.2
2. Ruby on Rails 8.0.2
3. Devise
4. MySQL

■フロントエンド
1. React
2. Vite
3. JavaScript
4. HTML / CSS / Bootstrap

■認証
1. Firebase Authentication
2. Google OAuth

■インフラ
1. AWS EC2
2. Nginx 1.24.0
3. Puma 7.1.0
4. Let's Encrypt SSL　certbot 2.9.0

■バージョン管理
1. Git
2. GitHub

■システム構成
[Google]
  ↓ 
[Firebase Authentication]
  ↓
[React Frontend]
https://ariaguma.jp/react
  ↓ Firebase ID Token
[Rails API]
https://ariaguma.jp/google_login
  ↓
[MySQL]

■AWS構成
Internet
    ↓
Nginx
    │
    ├─ React (静的配信)
    │     /react
    └─ Rails(Puma)
          ↓
        MySQL

■構成内容
・EC2 上に Rails / React を同居
・Nginx によるリバースプロキシ構成
・React は静的ファイルとして配信
・Rails は Puma で稼働
・SSL 化（HTTPS対応）
・ドメイン取得・DNS設定実施

◆機能一覧
■ユーザー機能
・ユーザー登録
・ログイン
・ログアウト
・電子書籍ダウンロード
・プロフィール管理
・トークン付きダウンロード機能  

■管理機能
・ユーザー管理
・コンテンツ管理
・ダウンロード管理
・CRUD機能

■Google認証機能
・Googleログイン
・Firebase認証
・Railsセッション生成
・ログイン状態保持
・ログアウト

◆Google認証の流れ
ユーザーがGoogleログインボタン押下
         ↓
Firebase Authenticationで認証
         ↓
Firebase ID Token取得
         ↓
React→Railsへ送信
         ↓
Railsでトークン検証
         ↓
ユーザー検索
         ↓
Rails Session作成
         ↓
ログイン完了

◆Firebase採用理由
Googleログインを安全かつ短期間で実装するため採用しました。

■採用メリット
1. OAuth実装を簡略化できる
2. Google認証を安全に利用可能
3. JWTトークン管理が容易
4. Reactとの親和性が高い
5. 将来的なSNSログイン追加が容易

◆工夫した点
■認証連携
React と Rails を別構成で運用しながら認証を統合しました。
Firebase が発行する ID Token を Rails 側で検証し、
Rails セッションへ変換する構成を実装しています。

■実装内容
・Firebase JWT検証
・Rails Session生成
・Cookie認証
・HTTPS対応
・SameSite設定
・Google OAuth連携

◆セキュリティ
・HTTPS通信
・Rails Session管理
・HttpOnly Cookie
・Firebaseトークン検証
・CSRF対策
・権限制御

◆インフラ
AWS上で本番環境を構築しました。

■対応内容
・EC2構築
・Linux設定
・Nginx設定
・Puma設定
・SSL設定
・ドメイン設定
・デプロイ作業

◆要件定義
■目的■
　Googleアカウントによる簡単なログイン機能を提供する。
■要件■
■機能要件
・Googleログイン
・ログアウト
・ログイン状態保持
・ログインユーザー情報取得
■非機能要件
・HTTPS通信
・セッション管理
・認証情報の安全な管理

◆基本設計
■フロントエンド
　React
■役割
・Google認証実行
・Firebaseトークン取得
・Rails API呼び出し
■バックエンド
　Rails
■役割
・JWT検証
・ユーザー検索
・セッション生成

◆詳細設計
■API
■POST
　/google_login
■Request
{
  "credential": "Firebase ID Token"
}
■Response
{
  "success": true,
  "user": {
    "id": 2,
    "email": "sample@example.com",
    "name": "User Name"
  }
}
◆アピールポイント
本システムでは、
・要件定義
・設計
・実装
・テスト
・AWS構築
・デプロイ
までを一貫して担当しました。
特に React・Firebase・Rails を連携した認証機能を設計から
実装まで行い、実際の本番環境で運用しています。
バックエンド開発だけでなく、フロントエンド・インフラ領域まで
含めたフルスタックな開発経験をアピールできるプロジェクトです。

◆画面イメージ
■ユーザー画面
■管理画面
■React Googleログイン画面
React + Firebase Authentication による Google ログイン機能を実装。
  
◆ユーザー画面  
<p align="left">
  <img src="https://github.com/J-kitten/ariaguma/blob/main/images/2026-06-08 093952.png">
</p>
◆管理画面  
<p align="center">
  <img src="https://github.com/J-kitten/ariaguma/blob/main/images/2026-06-08 095157.png">
</p>


