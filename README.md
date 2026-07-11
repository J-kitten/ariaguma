
◇ARIAGUMA電子書籍配布管理システム

◇概要
　ARIAGUMAは、電子書籍の配布・管理を目的とした
　WEBシステムです。利用者は会員登録後、電子書籍
　が完成後に管理者からダウンロードURL記述のメールが送られる。
　管理画面では利用者管理・書籍管理・メール送信/返信・
　ダウンロード管理を行えます。
　また、React + Firebase Authentication を利用した 
　Googleログイン機能を追加実装し、Railsとの認証連携
　を実現しています。

◇また、React + Firebase Authentication を利用した 
　Google ログイン機能を実装し、既存 Rails システム
　との認証連携を行っています。

◇ユーザー画面　URL: https://ariaguma.jp/

◇管理画面　※管理者専用

◇使用技術
〇バックエンド
　Ruby 3.2.2
　Ruby on Rails 8.0.2
　Nginx 1.24.0
　Puma 7.1.0
　Vite 
　MySQL
〇フロントエンド
　React 19.1.0.
　JavaScript
　HTML | CSS
　Bootstrap
　Deviseログイン認証
　Firebase Authentication 12.14.0
　Google OAuth
〇インフラ
　AWS EC2
　Let's Encrypt SSL
〇バージョン管理
　Git
　GitHub

◇システム構成
　[Google]
    │
    ▼
　[Firebase Authentication]
    │
    ▼
　[React (Vite)]
    │ Firebase ログイン認証
    ▼
　[Rails API]
　https://ariaguma.jp/
    │
    ▼
　[MySQL]


◇AWS構成
　Internet
    │
    ▼
　Nginx
    │
    ├─ React (静的配信)
    │
    └─ Rails(Puma)
          │
          ▼
        MySQL

◇構成内容
　EC2 上に Rails / React を同居
　Nginx によるリバースプロキシ構成
　React は静的ファイルとして配信
　Rails は Puma で稼働
　SSL化（HTTPS対応）
　ドメイン取得・DNS設定実施
　機能一覧
　ユーザー機能
　ユーザー登録
　ログイン
　ログアウト
　電子書籍ダウンロード
　プロフィール管理
　管理機能
　ユーザー管理
　コンテンツ管理
　ダウンロード管理
　CRUD機能
　メールログイン機能
　Firebase Googleログイン認証機能
　Railsセッション生成
　ログイン状態保持
　ログアウト

◇Google認証の流れ
　1. ユーザーがGoogleログインボタン押下
            │
            ▼
　2. Firebase Authenticationで認証
            │
            ▼
　3. React→Railsへ送信
            │
            ▼
　4. ユーザー検索
            │
            ▼
　5. Rails Session作成
            │
            ▼
　6. ログイン完了


◇Firebase採用理由
　Googleログインを安全かつ短期間で実装するため採用しました。
◇採用メリット
　OAuth実装を簡略化できる
　Google認証を安全に利用可能
　JWTトークン管理が容易
　Reactとの親和性が高い
　将来的なSNSログイン追加が容易
　工夫した点
　認証連携

◇React と Rails を別構成で運用しながら認証を統合しました。
　Firebase が発行する ID Token を Rails 側で検証し、
　Rails セッションへ変換する構成を実装しています。

◇実装内容
　Firebase JWT検証
　Rails Session生成
　Cookie認証
　HTTPS対応
　SameSite設定
　Google OAuth連携
　セキュリティ
　HTTPS通信
　Rails Session管理
　HttpOnly Cookie
　Firebaseトークン検証
　CSRF対策
　権限制御
　インフラ
　AWS上で本番環境を構築しました。

◇対応内容
　EC2構築
　Linux設定
　Nginx設定
　Puma設定
　SSL設定
　ドメイン設定
　デプロイ作業
　要件定義

◇目的
　Googleアカウントによる簡単なログイン機能を提供する。

◇要件
　機能要件
　Googleログイン
　ログアウト
　ログイン状態保持
　ログインユーザー情報取得
　非機能要件
　HTTPS通信
　セッション管理
　認証情報の安全な管理
　基本設計

◇フロントエンド
　React

◇役割
　Google認証実行
　Firebaseトークン取得
　Rails API呼び出し
　バックエンド

◇Rails
　役割
　JWT検証
　ユーザー検索
　セッション生成
　詳細設計
　API
　POST

◇/google_login
〇Request
{
  "credential": "Firebase"
}
〇Response
{
  "success": true,
  "user": {
    "id": 2,
    "email": "sample@example.com",
    "name": "User Name"
  }
}

◇アピールポイント 本システムでは、
〇要件定義
　設計
　実装
　テスト
　AWS構築
　デプロイ
までを一貫して担当しました。

◇特に React・Firebase・Rails を連携した認証機能
　を設計から実装まで行い、実際の本番環境で運用しています。

◇バックエンド開発だけでなく、フロントエンド・
　インフラ領域まで含めたフルスタックな開発経験を
　アピールできるプロジェクトです。

◇画面イメージ
〇ユーザー画面
　<p align="left"> <img src="https://github.com/J-kitten/ariaguma/blob/main/%E3%83%A6%E3%83%BC%E3%82%B6%E3%83%BC%E7%94%BB%E9%9D%A2_2026-06-18%20015420.png"> </p>

〇管理画面
　<p align="center"> <img src="https://github.com/J-kitten/ariaguma/blob/main/%E7%AE%A1%E7%90%86%E7%94%BB%E9%9D%A2_2026-06-18%20015358.png"> </p>

〇React Googleログイン画面
　React + Firebase Authentication による Google ログイン機能を実装。
