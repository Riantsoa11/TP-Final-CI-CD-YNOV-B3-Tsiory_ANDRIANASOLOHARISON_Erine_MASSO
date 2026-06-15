# Architecture — ShopLite

## Vue d'ensemble

ShopLite est une application e-commerce minimaliste composée de 4 services Docker orchestrés par Docker Compose.

---

## Diagramme d'architecture

```mermaid
graph TB
    subgraph Client
        Browser["🌐 Navigateur"]
    end

    subgraph Docker["Docker Compose — shoplite_net"]
        Proxy["🔀 Proxy Nginx<br/>:8080<br/>(shoplite_proxy)"]

        subgraph App["Services applicatifs"]
            API["⚙️ API Node.js/Express<br/>:3000<br/>(shoplite_api)"]
            Frontend["🖥️ Frontend Nginx<br/>(shoplite_frontend)"]
        end

        subgraph Data["Persistance"]
            DB[("🐘 PostgreSQL 16<br/>:5432<br/>(shoplite_db)")]
            Volume[("💾 shoplite_pgdata<br/>Docker Volume")]
        end
    end

    subgraph Backups["Sauvegardes"]
        BackupDir["📁 ./backups/<br/>backup-YYYYMMDD.sql"]
    end

    Browser -->|"HTTP :8080"| Proxy
    Proxy -->|"GET /api/*"| API
    Proxy -->|"GET /*"| Frontend
    API -->|"SQL"| DB
    DB --- Volume
    DB -.->|"pg_dump"| BackupDir
```

---

## Flux de requête

```mermaid
sequenceDiagram
    participant B as Navigateur
    participant N as Nginx (proxy)
    participant A as API (Node.js)
    participant D as PostgreSQL

    B->>N: GET /api/products
    N->>A: GET /products (proxy_pass)
    A->>A: generate request_id
    A->>D: SELECT * FROM products
    D-->>A: rows[]
    A-->>N: 200 JSON + X-Request-Id
    N-->>B: 200 JSON
```

---

## Pipeline CI/CD

```mermaid
graph LR
    subgraph CI["CI — chaque push"]
        L["lint<br/>(ESLint + Prettier)"]
        T["test<br/>(Node 18 + 20<br/>+ PostgreSQL)"]
        B["build-docker<br/>(API + Frontend)"]
        S["security<br/>(Trivy scan)"]

        L --> B
        T --> B
        B --> S
    end

    subgraph CD["CD"]
        DS["deploy-staging<br/>(push develop)"]
        DP["deploy-production<br/>(tag v*)"]
    end

    S --> DS
    DS -->|"review manuelle"| DP
```

---

## Flux de rollback

```mermaid
graph TD
    A["🚨 Incident détecté<br/>(tests rouges / 500)"]
    B["📦 Vérifier backup<br/>bash scripts/backup.sh"]
    C["🔍 Identifier version stable<br/>docker images shoplite-api"]
    D["⏪ Rollback image<br/>bash scripts/rollback.sh v1.0.0"]
    E["✅ Smoke tests<br/>/health + /products"]
    F["🔧 Corriger le code source<br/>git revert HEAD"]
    G["🏗️ Rebuild image<br/>docker compose up -d --build api"]
    H["✅ Tests complets<br/>npm test"]

    A --> B --> C --> D --> E --> F --> G --> H
```

---

## Services Docker

| Service | Image | Port exposé | Rôle |
|---------|-------|-------------|------|
| `shoplite_proxy` | `nginx:1.27-alpine` (custom) | `8080:80` | Reverse proxy, point d'entrée unique |
| `shoplite_api` | `node:20-alpine` (multi-stage) | interne :3000 | API REST Node.js/Express |
| `shoplite_frontend` | `nginx:1.27-alpine` (custom) | interne :80 | Fichiers statiques HTML/CSS/JS |
| `shoplite_db` | `postgres:16-alpine` (custom) | `5432:5432`* | Base de données relationnelle |

*Port exposé en développement uniquement pour les tests Jest locaux.

---

## Choix techniques

| Décision | Choix | Raison |
|----------|-------|--------|
| Runtime API | Node.js 20 LTS | Stabilité + support long terme |
| Base image Docker | Alpine | Image minimale (~50 MB vs ~300 MB Debian) |
| Build multi-stage | deps → runner | Exclut devDependencies et npm cache de l'image finale |
| User non-root | `USER node` | Principe du moindre privilège |
| Sans bind mount | Dockerfiles custom pour db et nginx | Compatibilité Windows (espaces dans les chemins) |
| Logs structurés | JSON sur stdout | Compatible avec tous les agrégateurs de logs (ELK, Loki…) |
| Rollback | Image taguée + `API_VERSION` env var | Rollback instantané sans rebuild |

---

## Variables d'environnement

| Variable | Défaut | Description |
|----------|--------|-------------|
| `POSTGRES_DB` | `shoplite` | Nom de la base de données |
| `POSTGRES_USER` | `shoplite` | Utilisateur PostgreSQL |
| `POSTGRES_PASSWORD` | *(requis)* | Mot de passe PostgreSQL |
| `DATABASE_URL` | — | URL de connexion complète pour l'API |
| `API_PORT` | `3000` | Port d'écoute de l'API |
| `LOG_LEVEL` | `info` | Niveau de log (debug/info/warn/error/fatal) |
| `APP_VERSION` | `1.0.0` | Version affichée dans `/health` |
| `API_VERSION` | `latest` | Tag d'image utilisé au rollback |
| `HTTP_PORT` | `8080` | Port public du proxy Nginx |
