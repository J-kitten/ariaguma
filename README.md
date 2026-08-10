
# ARIAGUMA電子書籍配布管理システム

◆概要
　ARIAGUMAは電子書籍の配布・管理を目的としたRailsで開発した
　WEBシステムです。

- **Backend**: Ruby on Rails 8
- **Frontend**: React + Vite
- **Authentication**: Firebase Authentication / 独自セッション認証
- **Infrastructure**: AWS EC2 + Nginx + Puma + MySQL

　ユーザーは予約登録を行い、電子書籍の完成後にメールで送付な
　されるダウンロードURLやマイページから電子書籍を取得できます。
　また、お問い合わせやマイページでの情報確認・返信も行えます。

　管理画面では、
　・ユーザー管理
　・電子書籍管理
　・メール返信
　・ダウンロード管理
　などを行えます。

　さらに React + Firebase Authentication を利用したGoogleログ
　イン機能を実装し、Railsとの認証連携を実現しています。


◆ユーザー画面　URL: https://ariaguma.jp/

◆管理画面　※管理者専用

◆使用技術
○バックエンド
　Ruby 3.2.2
　Ruby on Rails 8.0.2
　Nginx 1.24.0
　Puma 7.1.0
　Vite 
　MySQL
○フロントエンド
　React 19.1.0.
　JavaScript
　HTML | CSS
　Bootstrap
　[管理画面]
　・独自セッション認証
　[ユーザー画面]
　・Firebase Authenticationログイン認証（12.14.0）
　・Google OAuth
○インフラ
　AWS EC2
　Let's Encrypt SSL
○バージョン管理
　Git
　GitHub

◆システム構成
　[Google]
    │
    ▼
　[Firebase Authentication]
    │
    ▼
　[React]
    │ Firebase ログイン認証
    ▼
　[Rails API]
　https://ariaguma.jp/
    │
    ▼
　[MySQL]


◆AWS構成
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

◆構成内容
　EC2上に Rails / React
　Nginx によるリバースプロキシ構成
　Puma が Railsアプリケーションサーバー
　React は静的ファイルとして配信
　SSL化（HTTPS対応）
　ドメイン取得・DNS設定

◆機能一覧
○Firebaseユーザー機能
　ユーザー登録
　Firebase Authenticationログイン
　ログアウト
　電子書籍PDFファイルのトークンを用いたダウンロード
　マイページ
　プロフィール管理

○管理機能
　GMAILタイプの画面機能
　独自セッション認証
　予約登録・お問合せ対応
　ユーザーへメールで完成書籍のお知らせ機能
　電子書籍PDFファイルの登録・アップロード
　CRUD機能

○Firebase Googleログイン認証機能
　Railsセッション生成
　ログイン状態保持
　ログアウト


◆Firebase採用理由
　Googleログインを安全かつ短期間で実装するため採用しました。
◆採用メリット
　OAuth実装を簡略化できる
　Google認証を安全に利用可能
　JWTトークン管理が容易
　Reactとの親和性が高い
　将来的なSNSログイン追加が容易
◆工夫した点
　認証連携

◆React と Rails を別構成で運用しながら認証を統合しました。
　Firebase が発行する ID Token を Rails 側で検証し、
　Rails セッションへ変換する構成を実装しています。

◆実装内容
・Firebase Authentication
・Google OAuth連携
・Rails Session生成
・Cookie認証
・権限制御

◆セキュリティ
・HTTPS通信
・ReactからX-CSRF-Tokenを送信し、Rails標準のCSRF対策を利用
・Rails Cookie Session管理
・HttpOnly Cookie
・SameSite Cookie
・SQLインジェクション対策（Active Record）
・XSS対策（Rails標準エスケープ）

◆対応内容
・要件整理
・AWSインフラ構築
・DB設計
・テーブル・カラム設計
・画面設計
・Rails実装
・React実装
・Firebase Authentication
・Nginx設定
・Puma設定
・SSL設定
・デプロイ
・ドメイン設定
・デプロイ作業

◆目的
　Googleアカウントによる簡単なログイン機能を提供する。

◆要件
○機能要件
　Googleログイン
　ログアウト
　ログイン状態保持
　ログインユーザー情報取得
○非機能要件
　HTTPS通信
　セッション管理
　認証情報の安全な管理

◆フロントエンドReact役割
　Google認証実行
　Firebaseトークン取得
　Rails API呼び出し

◆バックエンドRails役割
　JWT検証
　ユーザー検索
　セッション生成

◆詳細設計
### API
#### POST /firebase_login

○Request
{
  "id_token": "<Firebase ID Token>"
}
○Response
{
  "success": true,
  "user": {
    "id": 2,
    "email": "sample@example.com",
    "name": "User Name"
  }
}
○処理フロー
1. ReactでFirebase Authenticationによるログインを実行
2. Firebase IDトークンを取得
3. RailsへIDトークンを送信
4. Rails側でFirebase IDトークンを検証
5. ユーザーを検索し、存在しない場合は新規作成
6. session[:user_id] にユーザーIDを保存
7. RailsがセッションCookieを発行
8. Cookieを利用してログイン状態を保持
9. ログイン完了

◆今後の予定
・多言語対応
・電子書籍管理機能の拡張
・管理画面機能の改善
・CI/CD導入

◆工夫した点
・ReactとRailsを疎結合で構成
・Firebase AuthenticationとRails Sessionを連携
・Cookie認証によりログイン状態を維持
・管理画面とユーザー画面で認証方式を分離
・AWS上へ本番環境を構築

◆画面イメージ
○ユーザー画面 TOP
　<p align="left"> <img src="https://github.com/J-kitten/ariaguma/blob/main/my-images/1.png"> </p>

○ユーザー画面 マイページ|モーダル
　<p align="center"> <img src="https://github.com/J-kitten/ariaguma/blob/main/my-images/2.png"> </p>

○ユーザー画面 マイページ
　<p align="center"> <img src="https://github.com/J-kitten/ariaguma/blob/main/my-images/3.png"> </p>

○ユーザー画面 マイページ ダウンロード
　<p align="center"> <img src="https://github.com/J-kitten/ariaguma/blob/main/my-images/4.png"> </p>

○ユーザー画面 マイページ プロフィール再設定
　<p align="center"> <img src="https://github.com/J-kitten/ariaguma/blob/main/my-images/5.png"> </p>

○管理画面 ログイン
　<p align="center"> <img src="https://github.com/J-kitten/ariaguma/blob/main/my-images/6.png"> </p>

○管理画面 ダッシュボード
　<p align="center"> <img src="https://github.com/J-kitten/ariaguma/blob/main/my-images/7.png"> </p>

○管理画面 予約希望者
　<p align="center"> <img src="https://github.com/J-kitten/ariaguma/blob/main/my-images/8.png"> </p>

○管理画面 お問合せ
　<p align="center"> <img src="https://github.com/J-kitten/ariaguma/blob/main/my-images/9.png"> </p>

○管理画面 ダウンロード履歴
　<p align="center"> <img src="https://github.com/J-kitten/ariaguma/blob/main/my-images/10.png"> </p>

○管理画面 ダウンロード履歴詳細
　<p align="center"> <img src="https://github.com/J-kitten/ariaguma/blob/main/my-images/11.png"> </p>

○管理画面 PDFファイル管理
　<p align="center"> <img src="https://github.com/J-kitten/ariaguma/blob/main/my-images/12.png"> </p>

○管理画面 PDFファイル新規登録
　<p align="center"> <img src="https://github.com/J-kitten/ariaguma/blob/main/my-images/13.png"> </p>

○管理画面 PDFファイル編集
　<p align="center"> <img src="https://github.com/J-kitten/ariaguma/blob/main/my-images/14.png"> </p>

○AWS構成図
　<p align="center"> <img src="https://github.com/J-kitten/ariaguma/blob/main/my-images/15.png"> </p>

