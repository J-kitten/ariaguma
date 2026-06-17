flowchart LR

%% ======================
%% User
%% ======================
U[ユーザー（Browser）]

%% ======================
%% DNS / HTTPS
%% ======================
DNS[Route53 / DNS]
ACM[SSL証明書 (ACM)]

%% ======================
%% Web Layer
%% ======================
subgraph WEBサーバー
  NGINX[Nginx]
  PUMA[Puma (Rails)]
  VITE[Vite + React + TypeScript]
end

%% ======================
%% Firebase
%% ======================
subgraph Firebase
  AUTH[Firebase Authentication (Googleログイン)]
end

%% ======================
%% Admin
%% ======================
A[管理者（Browser）]
DEV[Devise認証（Rails Admin）]

%% ======================
%% App Server
%% ======================
RAILS[Rails Application]

%% ======================
%% DB
%% ======================
DB[(MySQL)]

%% ======================
%% Storage
%% ======================
FS[サーバーファイルストレージ<br/>/ariaguma/storage]

%% ======================
%% Flow
%% ======================

U --> DNS --> NGINX
NGINX --> VITE
NGINX --> PUMA

U --> AUTH
AUTH --> U

U --> PUMA
PUMA --> RAILS

RAILS --> DB
RAILS --> FS

A --> NGINX
A --> DEV
DEV --> RAILS
RAILS --> DB
