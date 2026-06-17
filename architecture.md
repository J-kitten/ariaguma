````md id="m9qv1k"
# AWS構成図（ユーザー画面 + 管理画面）

```mermaid
flowchart LR

U[User Browser]

NGINX[Nginx]
PUMA[Puma (Rails)]
VITE[Vite + React + TypeScript]

AUTH[Firebase Authentication]

ADMIN[Admin Browser]
DEV[Devise Login]

DB[(MySQL)]

U --> NGINX
NGINX --> VITE
NGINX --> PUMA

U --> AUTH

ADMIN --> DEV --> PUMA

PUMA --> DB
