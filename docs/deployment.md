# StellChat Deployment & Local Development

This document outlines the requirements and processes to run StellChat locally and deploy it to production environments.

---

## Environment Variables

Rename and configure these variables when deploying the backend.

| Environment Variable | Description | Default / Example |
|---|---|---|
| `STELLCHAT_ENV` | Mode of operation | `development` or `production` |
| `PORT` | Listening port for NestJS API | `3000` |
| `DATABASE_URL` | PostgreSQL connection string | `postgres://user:pass@localhost:5432/stellchat` |
| `REDIS_URL` | Redis instance connection string | `redis://localhost:6379/0` |
| `STELLCHAT_API_URL` | Base API URL public path | `https://api.stellchat.com` |

---

## Local Development Setup

### Prerequisite Components
- Node.js (v18+)
- Flutter SDK (v3.16+)
- Docker & Compose

### Running the Services
1. Clone the repository and navigate to the project directory.
2. Initialize environment:
   ```bash
   cp apps/backend/.env.example apps/backend/.env
   ```
3. Run the development docker container setup (spawns PostgreSQL and Redis):
   ```bash
   docker-compose up -d
   ```
4. Start the backend app:
   ```bash
   cd apps/backend
   npm install
   npm run start:dev
   ```
5. Start the mobile app:
   ```bash
   cd apps/mobile
   flutter pub get
   flutter run
   ```

---

## Production Deployment

### Docker Deployment
The project contains a production Docker configuration for deployment.

Build the multi-stage Docker image:
```bash
docker build -t stellchat/backend:latest -f apps/backend/Dockerfile .
```

### Render Deployment
StellChat is configured for Render via the root `render.yaml`:
```yaml
services:
  - type: web
    name: stellchat-backend
    env: node
    buildCommand: npm install && npm run build
    startCommand: npm run start:prod
    envVars:
      - key: STELLCHAT_ENV
        value: production
```
